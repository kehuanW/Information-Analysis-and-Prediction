import pandas as pd
from openpyxl import load_workbook


def csv_to_xlsx_pd():
    csv = pd.read_csv('DoubanRawData.csv', encoding='utf-8')
    csv.to_excel('DoubanRawData.xlsx', sheet_name='DoubanReview_RawData', index=False)
    csv = pd.read_csv('DoubanCleanData.csv', encoding='utf-8')
    csv.to_excel('DoubanCleanData.xlsx', sheet_name='DoubanReview_CleanData', index=False)
    csv = pd.read_csv('WeiboRawData.csv', encoding='utf-8')
    csv.to_excel('WeiboRawData.xlsx', sheet_name='WeiboReview_RawData', index=False)
    csv = pd.read_csv('WeiboCleanData.csv', encoding='utf-8')
    csv.to_excel('WeiboCleanData.xlsx', sheet_name='WeiboReview_CleanData', index=False)


def merge():
    df = pd.DataFrame({"id": [1, 2, 3], "name": ["Nick", "Bob", "Tom"]})
    df.to_excel('data.xlsx', index=False)

    writer = pd.ExcelWriter('data.xlsx')
    content = pd.read_excel('BiliViewsRawData.xls', encoding='utf-8')
    content.to_excel(writer, sheet_name='BiliViewsRawData',index=False)
    writer.save()

    writer = pd.ExcelWriter('data.xlsx', engine='openpyxl')
    book = load_workbook(writer.path)
    writer.book = book

    content = pd.read_excel('BiliViewsCleanData.xls', encoding='utf-8')
    content.to_excel(excel_writer=writer, sheet_name='BibiViewsCleanData', index=False)
    writer.save()
    content = pd.read_excel('DoubanRawData.xlsx', encoding='utf-8')
    content.to_excel(excel_writer=writer, sheet_name='DoubanReview_RawData', index=False)
    writer.save()
    content = pd.read_excel('DoubanCleanData.xlsx', encoding='utf-8')
    content.to_excel(excel_writer=writer, sheet_name='DoubanReview_CleanData', index=False)
    writer.save()
    content = pd.read_excel('WeiboRawData.xlsx', encoding='utf-8')
    content.to_excel(excel_writer=writer, sheet_name='WeiboReview_RawData', index=False)
    writer.save()
    content = pd.read_csv('WeiboCleanData.csv', encoding='utf-8')
    content.to_excel(excel_writer=writer, sheet_name='WeiboReview_CleanData', index=False)
    writer.save()

def run():
    csv_to_xlsx_pd()
    merge()
    print("All data merged successfully")