
import requests
from bs4 import BeautifulSoup
from selenium import webdriver  # 引入浏览器驱动
from selenium.webdriver.common.by import By  # 借助By模块进行操作
from selenium.webdriver.support.ui import WebDriverWait  # 显式等待
from selenium.webdriver.support import expected_conditions as Ec  # 显式等待的条件
import pandas as pd

def search(content):
    browser = webdriver.Chrome()# Get the browser object
    WAIT = WebDriverWait(browser, 10)  # Specify the maximum waiting time
    url = 'https://www.bilibili.com'
    # print('We start to visit bilibili')
    browser.get(url)

    # print('Searching...')
    # Select nodes with XPath
    input = WAIT.until(Ec.presence_of_element_located((By.XPATH, '//*[@id="nav_searchform"]/input')))
    submit = WAIT.until(Ec.element_to_be_clickable((By.XPATH, '//*[@id="nav_searchform"]/div')))

    # Enter from the search box and click search
    input.send_keys(content)
    submit.click()


# crawl:

    htmls = []  # Store the HTML of each page
    # Use a for loop to crawl each page and get its HTML
    # 40
    for i in range(40):
        url = f"https://search.bilibili.com/all?keyword=%E6%98%93%E7%83%8A%E5%8D%83%E7%8E%BA&page={str(int(i + 1))}"
        r = requests.get(url)
        if r.status_code != 200:
            raise Exception("error")
        htmls.append(r.text)



# parse

    videos = []  # 存放每个视频解析出来的HTML
    # print('Parsing the page...')
    for html in htmls:
        soup = BeautifulSoup(html, 'html.parser')
        video = soup.find(class_="video-list clearfix").find_all(class_="video-item matrix")
        videos.extend(video)

    items = []
    # print('Crawling related information...')
    for video in videos:
        item = {}
        item['video title'] = video.find('a')['title']
        item['video address'] = video.find('a')['href']
        item['introduction'] = video.find(class_='des hide').string
        item['views'] = video.find(class_='so-icon watch-num').get_text()
        item['release time'] = video.find(class_='so-icon time').get_text()
        item['# barrage'] = video.find(class_='so-icon hide').get_text()
        items.append(item)


# save_to_excel:

    # print('Successfully write data to file!')
    df = pd.DataFrame(items)
    df.to_excel("BiliViewsRawData.xls", sheet_name = 'BiliViewsRawData', encoding ='utf_8_sig')

    print('Bilibili video Info crawled successfully')
    browser.close()

def run():
    search('易烊千玺')


