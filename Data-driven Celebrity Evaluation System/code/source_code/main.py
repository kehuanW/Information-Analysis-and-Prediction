import BiliRawVideoInfoCrawl
import BiliCleanVideoInfo
import BiliDanmuCrawl
import DoubanRawDataCrawl
import DoubanCleanData
import WeiboRawDataCrawl
import WeiboCleanData
import BiliDanmuWordCloud
import DoubanWorldCloud
import Bilibili_Douban_DataAnalysis
import WeiboDataAnalysis_w12
import WeiboDataAnalysis_w345_v2
import WeiboDataAnalysis_w345
import DataMerge

command = input("Enter 1 : Crawl data and analyze the results. \nEnter 2 : Analyze crawled data.\n")

if command == '1':
    try:
        BiliRawVideoInfoCrawl.run()
        BiliCleanVideoInfo.run()
        BiliDanmuCrawl.run()
        DoubanRawDataCrawl.run()
        DoubanCleanData.run()
        WeiboRawDataCrawl.run()
        WeiboCleanData.run()
        DataMerge.run()

    finally:
        print("We start to analyze data now")
        BiliDanmuWordCloud.run()
        DoubanWorldCloud.run()
        Bilibili_Douban_DataAnalysis.BiliViewAnalysis()
        Bilibili_Douban_DataAnalysis.DoubanDataAnysis()
        WeiboDataAnalysis_w12.run()
        WeiboDataAnalysis_w345_v2.run()

elif command == '2':
    BiliDanmuWordCloud.run()
    DoubanWorldCloud.run()
    Bilibili_Douban_DataAnalysis.BiliViewAnalysis()
    Bilibili_Douban_DataAnalysis.DoubanDataAnysis()
    WeiboDataAnalysis_w12.run()
    WeiboDataAnalysis_w345.run()

else:
    print("You entered a wrong command. Please try again!")
