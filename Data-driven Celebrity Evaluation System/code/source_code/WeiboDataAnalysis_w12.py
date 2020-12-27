import pandas as pd
import xlrd
import xlwt
import matplotlib.pyplot as plt


def run():
    # read data from excel
    # data = pd.read_excel('Data_Source.xlsx', sheet_name='WeiboReview_CleanData')
    data = pd.read_excel('data.xlsx', sheet_name='WeiboReview_CleanData')
    workBook = xlrd.open_workbook('data.xlsx');
    # 1.get the names of sheet
    # 1.1 get all sheets' names in the list
    allSheetNames = workBook.sheet_names();
    # 1.2 use index to get specific sheet:WeiboReview_CleanData
    sheet6Name = workBook.sheet_names()[5];
    # print(sheet1Name);
    # 2. get the content of sheet by index
    sheet5_content = workBook.sheet_by_index(5);
    # 3. get the value in each row
    col2 = sheet5_content.col_values(1);
    col3 = sheet5_content.col_values(2);

    # define the function to get the num of each type
    def get_all_num_1(dataframe):
        repost_num = 0
        without_pic_num = 0
        with_pic_num = 0
        for i in dataframe:
            if i == 'repost':
                repost_num += 1
            if i == 'original without pic':
                without_pic_num += 1
            if i == 'original with pic':
                with_pic_num += 1
        return repost_num, without_pic_num, with_pic_num

    # define the function to get the num of each content
    def get_all_num_2(dataframe):
        all_str = ''
        a_num = 0
        b_num = 0
        for i in dataframe:
            all_str = str(i)
            for i in all_str:
                if i == '@':
                    a_num += 1
                    break
                if i == '#':
                    b_num += 1
                    break
        return a_num, b_num, len(dataframe)

    # define the function to get the num of each content
    def get_num():
        time_list = []
        kk_list = []
        kkk_list = []
        lll_list = []
        a_list = []
        b_list = []
        for i in data['Post time']:
            time_list.append(str(i).split(' ')[0])
        for i in range(0, 889, 30):
            kk_list.append(i)
            kkk_list.append(i + 30)
        for i in range(len(kk_list)):
            sum_num = 0
            a_num = 0
            b_num = 0
            for j in range(kk_list[i], kkk_list[i]):
                if j > 889:
                    break
                if data['Type'][j] == 'repost':
                    sum_num += 1
                content_str = data['content'][j]
                for ii in str(content_str):
                    if ii == '@':
                        a_num += 1
                    if ii == '#':
                        b_num += 1
            lll_list.append(sum_num)
            a_list.append(a_num)
            b_list.append(b_num)
        labels = []
        for j in kk_list:
            labels.append(time_list[j])
        labels.reverse()
        c_list = []
        for i in range(len(a_list)):
            c_list.append(a_list[i] + b_list[i])
        return lll_list, a_list, b_list, c_list, labels, time_list

    # define the function to draw pie chart of weibo type
    def png_1(repost_num, without_pic_num, with_pic_num):
        labels = 'repost', 'original without pic', 'original with pic'
        sizes = repost_num, without_pic_num, with_pic_num
        colors = 'dodgerblue', 'skyblue', 'lightgreen', 'lightcoral'
        plt.pie(sizes, labels=labels,
                colors=colors, autopct='%1.1f%%', shadow=True, startangle=50)
        plt.axis('equal')
        plt.title('Pie chart of Weibo type')
        plt.savefig('Weibo_type_pie')
        plt.show()

    # define the function to draw bar chart of weibo type
    def png_2(repost_num, without_pic_num, with_pic_num):
        labels = ('repost', 'original without pic', 'original with pic')
        sizes = [repost_num, without_pic_num, with_pic_num]
        plt.bar(labels, sizes)
        plt.title('Bar chart of Weibo type')
        plt.savefig('Weibo_type_bar')
        plt.show()

    # define the function to draw pie chart of weibo content
    def png_3(num_1, num_2):
        labels = '@and#_num', 'other_num'
        sizes = num_1, num_2
        colors = 'hotpink', 'mistyrose'
        plt.pie(sizes, labels=labels,
                colors=colors, autopct='%1.1f%%', shadow=True, startangle=50)
        plt.axis('equal')
        plt.title('contents contain @ or #')
        plt.savefig('Weibo_pie_@and#')
        plt.show()

    # draw charts
    repost_num, without_pic_num, with_pic_num = get_all_num_1(col2)
    png_1(repost_num, without_pic_num, with_pic_num)  # pie of type
    png_2(repost_num, without_pic_num, with_pic_num)  # bar of type

    a, b, num = get_all_num_2(col3)
    a_num = a / num
    b_num = b / num
    c_num = (a + b) / num

    png_3(a + b, num - a - b)  # pie of contents

    # lll_list, a_list, b_list, c_list, labels, time_list = get_num()

