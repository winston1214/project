# coding: utf-8


import argparse
import pandas as pd
import os
import torch
from torch import nn
import torch.nn.functional as F
import torch.optim as optims
from torch.utils.data import Dataset, DataLoader
import gluonnlp as nlp
import numpy as np
from tqdm import tqdm, tqdm_notebook

from kobert.utils import get_tokenizer
from kobert.pytorch_kobert import get_pytorch_kobert_model

from transformers import AdamW
from transformers.optimization import get_cosine_schedule_with_warmup
def bert_train(opt):
    device = torch.device('cuda:{}'.format(opt.device))

    bertmodel, vocab = get_pytorch_kobert_model()



    dataset_train = nlp.data.TSVDataset('{}'.format(opt.source), field_indices=[1,2], num_discard_samples=1)
    # dataset_test = nlp.data.TSVDataset('/content/tst.txt', field_indices=[1,2], num_discard_samples=1)


    tokenizer = get_tokenizer()
    tok = nlp.data.BERTSPTokenizer(tokenizer, vocab, lower=False)




    class BERTDataset(Dataset):
        def __init__(self, dataset, sent_idx, label_idx, bert_tokenizer, max_len,
                     pad, pair):
            transform = nlp.data.BERTSentenceTransform(
                bert_tokenizer, max_seq_length=max_len, pad=pad, pair=pair)

            self.sentences = [transform([i[sent_idx]]) for i in dataset]
            self.labels = [np.int32(i[label_idx]) for i in dataset]

        def __getitem__(self, i):
            return (self.sentences[i] + (self.labels[i], ))

        def __len__(self):
            return (len(self.labels))


    max_len = 256 # 해당 길이를 초과하는 단어에 대해선 bert가 학습하지 않음
    batch_size = opt.batch
    warmup_ratio = 0.1
    num_epochs = 2
    max_grad_norm = 1
    log_interval = 200
    learning_rate = 5e-5



    data_train = BERTDataset(dataset_train, 0, 1, tok, max_len, True, False)




    # pytorch용 DataLoader 사용
    train_dataloader = torch.utils.data.DataLoader(data_train, batch_size=batch_size, num_workers=5)
    # test_dataloader = torch.utils.data.DataLoader(data_test, batch_size=batch_size, num_workers=5)



    class BERTClassifier(nn.Module):
        def __init__(self,
                     bert,
                     hidden_size = 768,
                     num_classes = opt.classes, # softmax 사용 <- binary일 경우는 2
                     dr_rate=None,
                     params=None):
            super(BERTClassifier, self).__init__()
            self.bert = bert
            self.dr_rate = dr_rate

            self.classifier = nn.Linear(hidden_size , num_classes)
            if dr_rate:
                self.dropout = nn.Dropout(p=dr_rate)

        def gen_attention_mask(self, token_ids, valid_length):
            attention_mask = torch.zeros_like(token_ids)
            for i, v in enumerate(valid_length):
                attention_mask[i][:v] = 1
            return attention_mask.float()

        def forward(self, token_ids, valid_length, segment_ids):
            attention_mask = self.gen_attention_mask(token_ids, valid_length)

            _, pooler = self.bert(input_ids = token_ids, token_type_ids = segment_ids.long(), attention_mask = attention_mask.float().to(token_ids.device))
            if self.dr_rate:
                out = self.dropout(pooler)
            return self.classifier(out)



    model = BERTClassifier(bertmodel, dr_rate=0.2).to(device)
    # model = torch.load('weights/last_kobert_pytorch_model_big2s.pt')
    # if torch.cuda.device_count() > 1:
        # model = nn.DataParallel(model)
    model = nn.DataParallel(model, output_device=[0,1])
    # model.to(device)



    # Prepare optimizer and schedule (linear warmup and decay)
    no_decay = ['bias', 'LayerNorm.weight']
    optimizer_grouped_parameters = [
        {'params': [p for n, p in model.named_parameters() if not any(nd in n for nd in no_decay)], 'weight_decay': 0.01},
        {'params': [p for n, p in model.named_parameters() if any(nd in n for nd in no_decay)], 'weight_decay': 0.0}
    ]




    # 옵티마이저 선언
    optimizer = AdamW(optimizer_grouped_parameters, lr=learning_rate)
    loss_fn = nn.CrossEntropyLoss() # softmax용 Loss Function 정하기 <- binary classification도 해당 loss function 사용 가능

    t_total = len(train_dataloader) * num_epochs
    warmup_step = int(t_total * warmup_ratio)

    scheduler = get_cosine_schedule_with_warmup(optimizer, num_warmup_steps=warmup_step, num_training_steps=t_total)

    # lr_scheduler = optims.lr_scheduler.CosineAnnealingLR(optimizer,T_max=0.1,eta_min=0.0001)


    # 학습 평가 지표인 accuracy 계산 -> 얼마나 타겟값을 많이 맞추었는가
    def calc_accuracy(X,Y):
        max_vals, max_indices = torch.max(X, 1)
        train_acc = (max_indices == Y).sum().data.cpu().numpy()/max_indices.size()[0]
        return train_acc



    # 모델 학습 시작
    for e in range(num_epochs):
        train_acc = 0.0
        test_acc = 0.0
        best_acc = 0.0
        model.train()
        for batch_id, (token_ids, valid_length, segment_ids, label) in enumerate(tqdm_notebook(train_dataloader)):
            optimizer.zero_grad()
            token_ids = token_ids.long().to(device)
            segment_ids = segment_ids.long().to(device)
            valid_length= valid_length
            label = label.long().to(device)
            out = model(token_ids, valid_length, segment_ids)
            loss = loss_fn(out, label)
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_grad_norm) # gradient clipping
            optimizer.step()
            scheduler.step()  # Update learning rate schedule
            # lr_scheduler.step()
            train_acc += calc_accuracy(out, label)
            if batch_id % log_interval == 0:
                print("epoch {} batch id {} loss {} train acc {}".format(e+1, batch_id+1, loss.data.cpu().numpy(), train_acc / (batch_id+1)))
            if train_acc > best_acc:
                best_acc = train_acc
            torch.save(model, '{}.pt'.format(opt.save_weights_name))
        print("epoch {} train acc {}".format(e+1, train_acc / (batch_id+1)))

    torch.save(model, '{}.pt'.format(opt.save_weights_name))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=str, default='train_big.txt', help='source')
    parser.add_argument('--save-weights-name', type=str, default='bert_train.pt', help='save weights name')
    parser.add_argument('--device', type=int, default=0, help='cuda 0 or 1 or ..')
    parser.add_argument('--classes',type=int,default=21,help='class num')
    parser.add_argument('--batch',type=int,default=64,help='batch-size')
    opt = parser.parse_args()
    bert_train(opt)
