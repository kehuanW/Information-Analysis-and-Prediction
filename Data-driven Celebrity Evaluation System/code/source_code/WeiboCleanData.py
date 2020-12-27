import pandas as pd
import csv
import time
import os
#import data
def run():
    tmp_lst = []
    data = 'WeiboRawData.csv'
    with open(data, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        for row in reader:
            tmp_lst.append(row)

    df = pd.DataFrame(tmp_lst[1:], columns=tmp_lst[0])

    # print all
    pd.set_option('display.max_columns', None)
    pd.set_option('display.max_rows', None)

    # process Likes
    for v in range(len(df['Likes'])):
        df['Likes'][v] = df['Likes'][v].replace('赞[', '')
        df['Likes'][v] = df['Likes'][v].replace(']', '')

    # Repost
    for v in range(len(df['Repost'])):
        df['Repost'][v] = df['Repost'][v].replace('转发[', '')
        df['Repost'][v] = df['Repost'][v].replace(']', '')

    # Comment
    for v in range(len(df['Comment'])):
        df['Comment'][v] = df['Comment'][v].replace('评论[', '')
        df['Comment'][v] = df['Comment'][v].replace(']', '')

    # Post time
    for v in range(len(df['Post Time'])):
        if '今天' in df['Post Time'][v]:
            df['Post Time'][v] = time.strftime("%Y-%m-%d", time.localtime()) + df['Post Time'][v][-7:-1] + ':00'
        if '-' not in df['Post Time'][v]:
            for current_year in [2020,2019,2018,2017,2016,2015,2014,2013]:

                # df['Post Time'][v] = str(current_year) + '-' + df['Post Time'][v][0:2] + '-' + df['Post Time'][v][3:5] + \
                #                      df['Post Time'][v][-7:-1] + ':00'
                df['Post Time'][v] = str(current_year) + '/' + df['Post Time'][v][0:2] + '/' + df['Post Time'][v][3:5] + \
                                     df['Post Time'][v][-7:-1] + ':00'
        df['Post Time'][v] = df['Post Time'][v].strip()

    # Type
    for v in range(len(df['Type'])):
        if df['Type'][v] == '2':
            df['Type'][v] = 'original with pic'
        if df['Type'][v] == '1':
            df['Type'][v] = 'original without pic'
        if df['Type'][v] == '3':
            df['Type'][v] = 'repost'

    # store data
    path = os.getcwd()
    csvPath = path + '/WeiboCleanData.csv'
    df.to_csv('WeiboCleanData.csv', index=False, encoding="utf_8_sig")
    print("Weibo Clean Data generated successfully")
