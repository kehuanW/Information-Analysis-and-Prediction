import xlrd
import xlwt
import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
import numpy as np
import pandas as pd
import seaborn as sns
from scipy import stats,integrate
from xlrd import xldate_as_tuple#translate excel date into datetime
from datetime import datetime

def run():

    from xlrd import xldate_as_tuple  # 将excel日期转化为datetime格式需要用的库
    from datetime import datetime
    date = datetime(*xldate_as_tuple(41534.8942361111, 0))
    cell = date.strftime('%Y/%d/%m %H:%M:%S')
    cell
    # open excel
    workBook = xlrd.open_workbook('data.xlsx');
    # 1.get the names of sheet
    # 1.1 get all sheets' names in the list
    allSheetNames = workBook.sheet_names();
    # 1.2 use index to get specific sheet:WeiboReview_CleanData
    sheet6Name = workBook.sheet_names()[5];
    #print(sheet1Name);
    # 2. get the content of sheet by index
    sheet5_content = workBook.sheet_by_index(5);
    # 3. get the value in each row
    col3 = sheet5_content.col_values(3); # get the number of likes
    col4 = sheet5_content.col_values(4); # get the number of reposts
    col5 = sheet5_content.col_values(5); # get the number of comments
    col6 = sheet5_content.col_values(6); # get the number of time
    # 4.get the number of rows
    row_num=sheet5_content.nrows
    # 5. draw histogram for likes#
    list_num_likes=np.array(col3[1:])/1000
    list_num_reposts=np.array(col4[1:])/1000
    list_num_comments=np.array(col5[1:])/1000
    comb=np.array([col3[1:],col4[1:],col5[1:]])/1000
    trend=pd.DataFrame(comb,columns=col6[1:],index=['likes','reposts','comments']).sort_index(axis=1)
    trend2=pd.DataFrame(trend.values.T,columns=trend.index,index=trend.columns)

    #translate time in excel into datetime
    new_time=[]
    for i in trend2.index[:]:
        date = datetime(*xldate_as_tuple(i, 0))
        cell = date.strftime('%Y/%d/%m %H:%M:%S')
        new_time.append(cell)
    trend2.index=new_time
    trend2.plot()
    plt.ylim(100, 4000)
    plt.xlabel('date from 2013.9.17 to 2020.11.19')
    plt.ylabel('thousands')
    plt.title('the popularity trend of Jackson Yi\'s Weibo')
    plt.savefig('Weibo_populariy_trend_total')
    plt.show()
    #show trendency of likes# change
    plt.plot(trend2.index,trend2.likes)
    plt.xlabel('date from 2013.9.17 to 2020.11.19')
    plt.ylabel('thousands of likes')
    plt.title('trend of the number of likes in Weibo')
    plt.xticks(())
    plt.savefig('Weibo_trend_likes')
    plt.show()
    #show trendency of reposts# change
    plt.plot(trend2.index,trend2.reposts)
    plt.xlabel('date from 2013.9.17 to 2020.11.19')
    plt.title('trend of the number of reposts in Weibo')
    plt.ylabel('thousands of reposts')
    plt.xticks(())
    plt.savefig('Weibo_trend_reposts')
    plt.show()
    #show trendency of comment# change
    plt.plot(trend2.index,trend2.comments)
    plt.xlabel('date from 2013.9.17 to 2020.11.19')
    plt.title('trend of the number of comments in Weibo')
    plt.ylabel('thousands of comments')
    plt.xticks(())
    plt.savefig('Weibo_trend_comments')
    plt.show()

    # use mil,h_mil,b_h_mil to represent three levels: above million, above half million and below
    mil=0
    h_mil=0
    b_h_mil=0
    for i in list_num_likes:
        if int(i)>=1000:
            mil+=1
        elif int(i)>=500 and int(i)<1000:
            h_mil+=1
        else:
            b_h_mil+=1
    mil=mil/row_num
    h_mil=h_mil/row_num
    b_h_mil=b_h_mil/row_num
    sns.distplot(list_num_likes,bins=200,kde=False,fit=stats.gamma)
    plt.xlim(0, 4000)
    plt.grid(axis="y")
    plt.grid(axis="x")
    plt.title('the distribution of likes in Weibo')
    plt.xlabel('thousands of likes')
    plt.savefig('Weibo_hist_likes')
    plt.show()

    # draw pie chart for likes#
    labels=['>=1 milion','0.5 million-1 million','<0.5 million']
    X=[mil,h_mil,b_h_mil]  
    fig = plt.figure()
    plt.pie(X,labels=labels,autopct='%1.2f%%',colors=['dodgerblue','skyblue','lightblue']) 
    plt.title("Pie chart of likes# in Weibo")
    plt.savefig('Weibo_pie_likes')
    plt.show()  
    # 6. draw histogram and pie chart for reposts
    mil=0
    h_mil=0
    b_h_mil=0
    for i in list_num_reposts:
        if i>=1000:
            mil+=1
        elif i>=500 and i<1000:
            h_mil+=1
        else:
            b_h_mil+=1
    mil=mil/row_num
    h_mil=h_mil/row_num
    b_h_mil=b_h_mil/row_num
    sns.distplot(list_num_reposts,bins=50,kde=False,fit=stats.gamma,color='red')
    plt.xlim(0, 1100)
    plt.grid(axis="y")
    plt.grid(axis="x")
    plt.title('the distribution of reposts in Weibo')
    plt.xlabel('thousands of reposts')
    plt.savefig('Weibo_hist_reposts')
    plt.show()
    # draw pie chart for repost#
    labels=['>=1 milion','0.5 million-1 million','<0.5 million']
    X=[mil,h_mil,b_h_mil]  
    fig = plt.figure()
    plt.pie(X,labels=labels,autopct='%1.2f%%',colors=['hotpink','lightpink','mistyrose']) 
    plt.title("Pie chart of repost# in Weibo")
    plt.savefig('Weibo_pie_reposts')
    plt.show()  
    # 7. draw histogram for comments#
    # use mil,h_mil,b_h_mil to represent three levels: above million, above half million and below
    mil=0
    h_mil=0
    b_h_mil=0
    for i in list_num_comments:
        if i>=1000:
            mil+=1
        elif i>=500 and i<1000:
            h_mil+=1
        else:
            b_h_mil+=1
    mil=mil/row_num
    h_mil=h_mil/row_num
    b_h_mil=b_h_mil/row_num
    sns.distplot(list_num_comments,bins=500,kde=False,fit=stats.gamma,color='green')
    plt.xlim(0, 1000)
    plt.ylim(0, 0.01)
    plt.grid(axis="y")
    plt.grid(axis="x")
    plt.title('the distribution of comments in Weibo')
    plt.xlabel('thousands of comments')
    plt.savefig('Weibo_hist_comments')
    plt.show()
    # draw pie chart for comments#
    labels=['>=1 milion','0.5 million-1 million','<0.5 million']
    X=[mil,h_mil,b_h_mil]  
    fig = plt.figure()
    plt.pie(X,labels=labels,autopct='%1.2f%%',colors=['forestgreen','limegreen','lightgreen']) 
    plt.title("Pie chart of comments# in Weibo")
    plt.savefig('Weibo_pie_cemments')
    plt.show()
