import pandas as pd
import numpy as np

def run():
    data = pd.read_excel("BiliViewsRawData.xls", header=0)
    data = np.array(data)

    length = len(data)
    # print(length)

    title = []
    for rowIdex in range(1, length):
        e = str(data[rowIdex][1]).replace('\n', '').strip()
        title.append(e)

    view = []
    for rowIdex in range(1, length):
        e = str(data[rowIdex][4]).replace('\n', '').strip()
        if '万' in e:
            d = e.replace('万', '')
            g = int(float(d) * 10000)
            view.append(g)
        else:
            view.append(int(e))

    d = {'title': title, 'view': view}
    # print(len(title), len(view))
    data1 = pd.DataFrame(d)
    # print(data1.duplicated())
    norepeat_data1 = data1.drop_duplicates(subset=['title'], keep='first')
    norepeat_sortedData = norepeat_data1.sort_values(by="view", ascending=False)
    dataResult = norepeat_sortedData.iloc[0: int(length * 0.2)]
    # ./DataSet/BiliCleanViewsData.xls
    dataResult.to_excel('BiliViewsCleanData.xls',sheet_name='BiliViewsCleanData',encoding='utf_8_sig')
    print('Bilibili video Info Clean Data comes out successfully')
