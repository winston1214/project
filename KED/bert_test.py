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
import pandas as pd
from kobert.utils import get_tokenizer
from kobert.pytorch_kobert import get_pytorch_kobert_model
import argparse
from transformers import AdamW
from transformers.optimization import get_cosine_schedule_with_warmup
def bert_test(opt):    
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

    device = torch.device('cuda:{}'.format(opt.device))
    model = torch.load(opt.weights)
    model.to(device)
    # model = nn.DataParallel(model, output_device=[0,1])
    bertmodel, vocab = get_pytorch_kobert_model()
    model.eval() # 평가 모드로 변경
    def calc_accuracy(X,Y):
        max_vals, max_indices = torch.max(X, 1)
        train_acc = (max_indices == Y).sum().data.cpu().numpy()/max_indices.size()[0]
        return train_acc

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
    tokenizer = get_tokenizer()
    tok = nlp.data.BERTSPTokenizer(tokenizer, vocab, lower=False)
    max_len = 256 # 해당 길이를 초과하는 단어에 대해선 bert가 학습하지 않음
    batch_size = opt.batch
    warmup_ratio = 0.1
    num_epochs = 2
    max_grad_norm = 1
    log_interval = 200
    learning_rate = 5e-5
    dataset_test = nlp.data.TSVDataset(opt.source, field_indices=[1,2], num_discard_samples=1)
    data_test = BERTDataset(dataset_test, 0, 1, tok, max_len, True, False)
    test_dataloader = torch.utils.data.DataLoader(data_test, batch_size=batch_size, num_workers=5)
    test_acc = 0.0
    df = pd.DataFrame(columns=['pred','label'])
    pred = np.array([])
    # answer = np.array([])
    for batch_id, (token_ids, valid_length, segment_ids, label) in enumerate(tqdm_notebook(test_dataloader)):
        token_ids = token_ids.long().to(device)
        segment_ids = segment_ids.long().to(device)
        valid_length= valid_length
        # label = label.long().to(device)
        out = model(token_ids, valid_length, segment_ids)
        _,max_idx = torch.max(out,1)
        pred = np.append(pred,max_idx.cpu().detach().tolist())
        # answer = np.append(answer,label.cpu().detach().tolist())
        # test_acc += calc_accuracy(out, label)
        # print(len(pred))
    df['pred'] = pred
    # df['label'] = answer
    df.to_csv(opt.save_csv_name,index=False)
    # print("test acc {}".format(test_acc / (batch_id+1)))
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=str, default='test.txt', help='source')
    parser.add_argument('--weights',type=str,default='bert.pt',help='weight_model path')
    parser.add_argument('--save_csv_name', type=str, default='', help='save csv name')
    parser.add_argument('--device', type=int, default=0, help='cuda 0 or 1 or ..')
    parser.add_argument('--classes',type=int,default=21,help='class num')
    parser.add_argument('--batch',type=int,default=32,help='batch-size')
    opt = parser.parse_args()
    bert_test(opt)
