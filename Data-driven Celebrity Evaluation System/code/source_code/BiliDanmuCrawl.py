import requests
import re

def run():
    # https://api.bilibili.com/x/v1/dm/list.so?oid=132586677
    url = 'https://api.bilibili.com/x/v1/dm/list.so?oid=132586677'

    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36'
    }

    response = requests.get(url, headers)
    response = response.content.decode('utf-8')
    data = re.compile('<d.*?>(.*?)</d>')
    danmu = data.findall(response)

    for line in danmu:
        with open('Danmu.txt', 'a', encoding='utf-8') as f:
            f.write(line + '\n')

    print('Bilibili Danmu Data crawled successfully')