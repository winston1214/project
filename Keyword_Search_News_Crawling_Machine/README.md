# Keyword Search News Crawling Machine

## Requirements
 - PyQt5
 - bs4
 - pandas
 - urllib
 - tkinter

## Search criteria🧐
1. Crawling articles within **a week**.
2. **Only those with keywords in the title** are saved in Excel.
3. **Naver** crawls the title of the **article, url, and abstract**, while Google crawls only the **title of the article, url**.

## Description
- If you check **OR** ,  **either word 1 or word 2** in the title to be saved in Excel.
- If you check **AND** , **both word 1 and word 2** must be in the title to be saved in Excel.
- If you check **None**, you **don't use the operator**. (Search a word)
- You can check both naver and google

## How to use?

**1. Excute crawlingui.py**
```
python crawlingui.py
```
 
<img src='https://github.com/AICT-CVAI/News_keyword_crawling/blob/master/img/display.png?raw=true'></img>


**2. Enter a Keyword**

<img src='https://github.com/AICT-CVAI/News_keyword_crawling/blob/master/img/check2.png?raw=true'></img>


✔ **You can also use Operator Option**

<img src="https://github.com/AICT-CVAI/News_keyword_crawling/blob/master/img/check1.png?raw=true"></img>

💥**If you use Operator Option, you should seperate words by comma(,)**

**3. Wait until the "save" window pops up.**

<img src='https://user-images.githubusercontent.com/47775179/119303582-f9ff9d00-bca0-11eb-80e7-b0c0a8bdf8af.png'></img>

**4. You will be able to get an Excel file**
- File name format = {Search Engine name} _ {keyword} _ result.xlsx
- save path = workspace directory

<img width="50%" height="50%" src='https://user-images.githubusercontent.com/47775179/119303580-f8ce7000-bca0-11eb-8412-e33b4fcb7334.png'></img>


⛔ **If there's no news within a week of keywords you're searching for, a warning msg pops up.**

<img width="30%" height="30%" src='https://user-images.githubusercontent.com/47775179/119303588-fb30ca00-bca0-11eb-9317-9cd38c60f523.png'></img>
