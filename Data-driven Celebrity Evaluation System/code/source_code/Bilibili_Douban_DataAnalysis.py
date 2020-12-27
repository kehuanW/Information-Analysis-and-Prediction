import xlrd
import xlwt
import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
import numpy as np
import pandas as pd
import seaborn as sns
from scipy import stats, integrate
from xlrd import xldate_as_tuple  # translate excel date into datetime
from datetime import datetime

def BiliViewAnalysis():
    workBook = xlrd.open_workbook('data.xlsx');
    sheet2_content = workBook.sheet_by_index(1);
    col2 = sheet2_content.col_values(2);  # get the number of Views
    row_num = sheet2_content.nrows
    list_num_views = np.array(col2[1:]) / 1000

    mil = 0
    h_mil = 0
    h_mil_b = 0
    b_h_mil = 0
    for i in list_num_views:
        if i >= 1000:
            mil += 1
        elif i >= 500:
            h_mil += 1
        elif i >= 300 and i < 500:
            h_mil_b += 1
        else:
            b_h_mil += 1
    mil = mil / row_num
    h_mil = h_mil / row_num
    h_mil_b = h_mil_b / row_num
    b_h_mil = b_h_mil / row_num
    sns.distplot(list_num_views, bins=200, kde=False, fit=stats.gamma)
    plt.xlim(0, 3000)
    plt.grid(axis="y")
    plt.grid(axis="x")
    plt.title('The Distribution of Views in Bilibili')
    plt.xlabel('Thousands of views')
    plt.savefig('Bili_hist_views')
    plt.show()
    # draw pie chart for likes#
    labels = ['>=1 million', '0.5million-1 million', '0.3 million-0.5 million', '<0.3 million']
    X = [mil, h_mil, h_mil_b, b_h_mil]
    fig = plt.figure()
    plt.pie(X, labels=labels, autopct='%1.2f%%', colors=['dodgerblue', 'deepskyblue', 'skyblue', 'lightblue'])
    #
    plt.title("Pie Chart of Views in Bilibili")
    plt.savefig('Bili_pie_views')
    plt.show()


def DoubanDataAnysis():
    # open excel
    workBook = xlrd.open_workbook('data.xlsx');
    sheet4_content = workBook.sheet_by_index(3);
    col3 = sheet4_content.col_values(2);
    row_num = sheet4_content.nrows
    list_num_likes = np.array(col3[1:])

    mil = 0
    h_mil = 0
    b_h_mil = 0
    for i in list_num_likes:
        if int(i) >= 1000:
            mil += 1
        elif int(i) >= 500 and int(i) < 1000:
            h_mil += 1
        else:
            b_h_mil += 1
    mil = mil / row_num
    h_mil = h_mil / row_num
    b_h_mil = b_h_mil / row_num

    labels = ['>=1000', '500-1000', '<500']
    X = [mil, h_mil, b_h_mil]
    fig = plt.figure()
    plt.pie(X, labels=labels, autopct='%1.2f%%', colors=['dodgerblue', 'skyblue', 'lightblue'])
    plt.title("Pie chart of Number of likes in Douban Comments")
    plt.savefig('Douban_pie_likes')
    plt.show()

    mil = 0
    h_mil = 0
    b_h_mil = 0
    for i in list_num_likes:
        if int(i) >= 1000:
            mil += 1
        elif int(i) >= 500 and int(i) < 1000:
            h_mil += 1
        else:
            b_h_mil += 1
    sns.distplot(list_num_likes, bins=500, kde=False, fit=stats.gamma, color='purple')
    plt.grid(axis="y")
    plt.grid(axis="x")
    plt.title('the distribution of likes in Douban')
    plt.xlim(0, 1000)
    plt.ylim(0, 0.005)
    plt.xlabel('Likes Number')
    plt.savefig('Douban_hist_comments')
    plt.show()
