import requests
from requests.exceptions import RequestException
from bs4 import BeautifulSoup
import csv
import re
import time
import random


def getHTMLText(url):
    headers = {
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36'
    }
    try:
        r = requests.get(url, headers=headers)
        r.raise_for_status()
        r.encoding = r.apparent_encoding
        return r.text
    except RequestException as e:
        print('error', e)

def fillUnivList(all_info,url):
    soup = BeautifulSoup(url, 'html.parser')
    for i in range(20):
        commentlist = soup.find_all('span',class_ = 'short')
        votes = soup.find_all('span',class_ = "votes")
        time = soup.find_all('span',class_ = "comment-time")
        score = soup.find_all('span', class_ = re.compile('(.*) rating'))
        m = '\d{4}-\d{2}-\d{2}'
        try:
            match = re.compile(m).match(score[i]['title'])
        except IndexError:
            break
        if match is not None:
            time = score
            score = ["null"]
        else:
            pass
        
        all_dict = { }
        all_dict["commentlist"] = commentlist[i].text
        all_dict["votes"] =  votes[i].text
        all_dict["time"] = time[i].text
        all_dict["score"] = score[i]['title']
        all_info.append(all_dict)
    return all_info

def printHtml_text(data):
      for ii in data:
            value_list = list(ii.values())
            with open ('DoubanComment.txt','a',encoding ='utf-8') as f:
                f.write(str(value_list)+'\n')
            
def printHtml_csv(data):
    with open('DoubanRawData.csv','w',encoding = 'utf-8-sig',newline = '') as csvfile:
        fieldnames=['评价','日期','评论','评论点赞']
        writer=csv.DictWriter(csvfile,fieldnames=fieldnames)
        writer.writeheader()
        for a in data:
            i = list(a.values())
            writer.writerow({'评价':i[3],'日期':i[2],'评论':i[0],'评论点赞':i[1]})

                        
def run():
    all_info = []
    for i in range(0,50,20):
        urls = ['https://movie.douban.com/subject/30166972/comments?start='+str(i)+'&limit=20&sort=new_score&status=P']
        for url in urls:
            time.sleep(round(random.uniform(3, 5), 2))
            html = getHTMLText(url)
            data = fillUnivList(all_info,html)
            printHtml_text(data)
            print("Douban comments Data crawled successfully")
            printHtml_csv(data)
            print("Douban Raw Data crawled successfully")