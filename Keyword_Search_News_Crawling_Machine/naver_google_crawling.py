import pandas as pd
import bs4
from urllib.request import urlopen
import urllib
import time
import tkinter as tk
from tkinter import messagebox
def naver(keyword,op='None'):
    searching = '''{}'''.format(keyword)
    searching = searching.strip()
    if op == 'AND': # AND 조건으로 검색
        tmp = list(map(lambda x: ''.join(filter(str.isalnum, x)),searching.split(','))) 
        op_searching = ' +'.join(tmp)
        word_encode = urllib.parse.quote(op_searching)
    else:
        word_encode = urllib.parse.quote(searching)
    df_list = []
    start=1
    key_list= [searching]
    if ',' in searching:
        key_list = list(map(lambda x: ''.join(filter(str.isalnum, x)),searching.split(',')))
    while True:
        url='https://search.naver.com/search.naver?where=news&sm=tab_jum&query={}&pd=1&start={}'.format(word_encode,start)
        source = urlopen(url).read()
        source = bs4.BeautifulSoup(source,'html.parser')
        title_path =  source.find_all('a',{'class':'news_tit'})
        abstract_path = source.find_all('a',{'class':'api_txt_lines dsc_txt_wrap'})
        if len(title_path) == 0:
            root = tk.Tk()
            msg = messagebox.showerror(title = "Naver No news",message = 'please search other keyword')
            if msg == 'ok':
                root.destroy()
                break

        for i in range(len(title_path)): # or 조건
            title = title_path[i].get('title')
            if op == 'OR' or op == 'None':
                if any(i in title for i in key_list):
                    abstract = abstract_path[i].text
                    link = title_path[i].get('href')
                    df = pd.DataFrame({'title':[title],'abstract':[abstract],'url':[link]})
                    df_list.append(df)
            if op == 'AND':
                if all(i in title for i in key_list):
                    abstract = abstract_path[i].text
                    link = title_path[i].get('href')
                    df = pd.DataFrame({'title':[title],'abstract':[abstract],'url':[link]})
                    df_list.append(df)        

        current_page = source.find_all('a',{'aria-pressed':'true'})[0].text
        last_page = source.find_all('a',{'aria-pressed':'false'})[-1].text
        if last_page == '문서 저장하기':
            break
        if int(current_page)>=int(last_page):
            break
        else:
            start += 10
        time.sleep(0.5)
        print('crawling...')
    if df_list: 
        naver_df = pd.concat(df_list)
        if op == 'AND' or op == 'OR':
            op_searching = searching.replace(',',f' {op} ')
            naver_df.to_excel('''naver_{}_result.xlsx'''.format(op_searching),index=False)
        else:
            naver_df.to_excel('''naver_{}_result.xlsx'''.format(searching),index=False)
        
        root2 = tk.Tk()
        msg = messagebox.showinfo(title='Save msg',message='Save!')
        if msg == 'ok':
            root2.destroy()
    else:
        root3 = tk.Tk()
        msg = messagebox.showerror(title = "Naver No news",message = 'please search other keyword')
        if msg == 'ok':
            root3.destroy()


def google(keyword,op='None'):
    searching = '''{}'''.format(keyword)
    searching = searching.strip()
    period = ' when:7d'
    if op != 'None':
        op_searching = searching.replace(',',f' {op} ')
        word_encode = urllib.parse.quote(op_searching+period)
    else:
        word_encode = urllib.parse.quote(searching+period)
    base_url = 'https://news.google.com/'
    url = 'https://news.google.com/search?q={}&hl=ko&gl=KR&ceid=KR:ko'.format(word_encode)
    source = urlopen(url).read()
    source = bs4.BeautifulSoup(source,'html.parser')
    df_list = []
    article_list = source.find_all('a',{'class':'DY5T1d RZIKme'})
    if len(article_list) == 0:
        root = tk.Tk()
        msg = messagebox.showerror(title = "Google No news",message = 'please search other keyword')
        if msg == 'ok':
            root.destroy()
    else:
        key_list= [searching]
        if ',' in searching:
            key_list = list(map(lambda x: ''.join(filter(str.isalnum, x)),searching.split(',')))
        for i in range(len(article_list)):
            title = article_list[i].text
            if op == 'OR' or op == 'None':
                if any(i in title for i in key_list):
                    link = base_url + article_list[i].get('href')[1:]
                    df = pd.DataFrame({'title':[title],'url':[link]})
                    df_list.append(df)
            if op == 'AND':
                if all(i in title for i in key_list):
                    link = base_url + article_list[i].get('href')[1:]
                    df = pd.DataFrame({'title':[title],'url':[link]})
                    df_list.append(df)
        
        if df_list:
            google_df = pd.concat(df_list)
            if op != 'None':
                google_df.to_excel('''google_{}_result.xlsx'''.format(op_searching),index=False)
            else:
                google_df.to_excel('''google_{}_result.xlsx'''.format(searching),index=False)
            root2 = tk.Tk()
            msg = messagebox.showinfo(title='Save msg',message='Save!')
            if msg == 'ok':
                root2.destroy()
        else:
            root3 = tk.Tk()
            msg = messagebox.showerror(title = "Google No news",message = 'please search other keyword')
            if msg == 'ok':
                root3.destroy()
