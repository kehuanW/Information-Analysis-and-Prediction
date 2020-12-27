import os
import time
import pickle
from tqdm import *
from selenium import webdriver
from bs4 import BeautifulSoup
import pandas as pd

def run():
    path = os.getcwd()
    csvPath = path + '/WeiboRawData.csv'

    # create dataframe
    df = pd.DataFrame(columns=('Num.', 'Type', 'Content', 'Likes', 'Repost', 'Comment', 'Post Time'))
    pd.set_option('display.max_columns', None)
    pd.set_option('max_colwidth', 150)
    pd.set_option('display.width', 1000)

    try:
        print(u'Login weibo...')
        ##open Firefox browser
        browser = webdriver.Firefox()
        ##login website
        url = 'https://passport.weibo.cn/signin/login'
        browser.get(url)
        time.sleep(3)
        # auto-login
        username = browser.find_element_by_css_selector('#loginName')
        time.sleep(2)
        username.clear()
        username.send_keys('###please modify it###')  # username
        # password
        password = browser.find_element_by_css_selector('#loginPassword')
        time.sleep(2)
        password.send_keys('###please modify it##') # password
        browser.find_element_by_css_selector('#loginAction').click()
        time.sleep(60)

    except:
        print('########出现Error########')
    finally:
        print('success!')

    # Yi Yangqianxi id is ‘u/3623353053’
    id = 'u/3623353053'
    niCheng = id
    # url = 'http://weibo.cn/' + id
    url = 'http://weibo.cn/' + id
    browser.get(url)
    time.sleep(3)

    # BeautifulSoup
    soup = BeautifulSoup(browser.page_source, 'lxml')
    # uid
    uid = soup.find('td', attrs={'valign': 'top'})
    uid = uid.a['href']
    uid = uid.split('/')[1]
    # max pagesize
    pageSize = soup.find('div', attrs={'id': 'pagelist'})
    pageSize = pageSize.find('div').getText()
    pageSize = (pageSize.split('/')[1]).split('页')[0]
    # num of weibo
    divMessage = soup.find('div', attrs={'class': 'tip2'})
    weiBoCount = divMessage.find('span').getText()
    weiBoCount = (weiBoCount.split('[')[1]).replace(']', '')
    # Following and Followers
    a = divMessage.find_all('a')[:2]
    guanZhuCount = (a[0].getText().split('[')[1]).replace(']', '')
    fenSiCount = (a[1].getText().split('[')[1]).replace(']', '')

    print("Following: ", guanZhuCount, "Followers: ", fenSiCount)

    # weibo information
    count = 1;
    for i in range(1, int(pageSize) + 1):  # pageSize
        # for i in range(31, 32):  # 5 pages
        # url = 'http://weibo.cn/' + id + ‘?page=’ + i
        url = 'http://weibo.cn/' + id + '?page=' + str(i)
        browser.get(url)
        time.sleep(1)
        # BeautifulSoup
        soup = BeautifulSoup(browser.page_source, 'lxml')
        body = soup.find('body')
        divss = body.find_all('div', attrs={'class': 'c'})[1:-2]
        for divs in divss:
            # yuanChuang : 0-repost，1-original
            yuanChuang = '1'
            div = divs.find_all('div')
            type = ""
            # 3 situation: original with pic, original post without pic, repost
            if (len(div) == 2):  # original with pic
                # type = 'Original & Pic'
                content = div[0].find('span', attrs={'class': 'ctt'}).getText()
                aa = div[1].find_all('a')
                for a in aa:
                    text = a.getText()
                    if (('赞' in text) or ('转发' in text) or ('评论' in text)):
                        # 爬取点赞数
                        if ('赞' in text):
                            # dianZan = (text.split('[')[1]).replace(']', '')
                            dianZan = text
                        # 爬取转发数
                        elif ('转发' in text):
                            # zhuanFa = (text.split('[')[1]).replace(']', '')
                            zhuanFa = text
                            # 爬取评论数目
                        elif ('评论' in text):
                            # pinLun = (text.split('[')[1]).replace(']', '')
                            pinLun = text
                            # 爬取微博来源和时间
                span = divs.find('span', attrs={'class': 'ct'}).getText()
                faBuTime = str(span.split('来自')[0])
                # laiYuan = span.split('来自')[1]

            elif (len(div) == 1):  # original post without pic
                # type = 'Original'
                content = div[0].find('span', attrs={'class': 'ctt'}).getText()
                aa = div[0].find_all('a')
                for a in aa:
                    text = a.getText()
                    if (('赞' in text) or ('转发' in text) or ('评论' in text)):
                        if ('赞' in text):
                            dianZan = text
                            # dianZan = (text.split('[')[1]).replace(']', '')
                        elif ('转发' in text):
                            zhuanFa = text
                            # zhuanFa = (text.split('[')[1]).replace(']', '')
                        elif ('评论' in text):
                            pinLun = text
                            # pinLun = (text.split('[')[1]).replace(']', '')
                span = divs.find('span', attrs={'class': 'ct'}).getText()
                faBuTime = str(span.split('来自')[0])
                # laiYuan = span.split('来自')[1]

            elif (len(div) == 3):  # 转发的微博
                # type = 'Repost'
                yuanChuang = '0'
                content = div[0].find('span', attrs={'class': 'ctt'}).getText()
                aa = div[2].find_all('a')
                for a in aa:
                    text = a.getText()
                    if (('赞' in text) or ('转发' in text) or ('评论' in text)):
                        if ('赞' in text):
                            dianZan = text
                            # dianZan = (text.split('[')[1]).replace(']', '')
                        elif ('转发' in text):
                            zhuanFa = text
                            # zhuanFa = (text.split('[')[1]).replace(']', '')
                        elif ('评论' in text):
                            pinLun = text
                            # pinLun = (text.split('[')[1]).replace(']', '')
                span = divs.find('span', attrs={'class': 'ct'}).getText()
                faBuTime = str(span.split('来自')[0])
                # laiYuan = span.split('来自')[1]

            new = pd.DataFrame(
                {'Num.': count, 'Type': len(div), 'Content': content, 'Likes': dianZan, 'Repost': zhuanFa,
                 'Comment': pinLun,
                 'Post Time': faBuTime}, index=[1])
            df = df.append(new, ignore_index=True)
            count = count + 1
        time.sleep(2)
        print(i)

    df.to_csv(csvPath, index=False, encoding="utf_8_sig")
    print("Weibo Raw Data crawled successfully")

