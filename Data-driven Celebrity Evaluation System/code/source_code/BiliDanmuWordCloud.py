import pandas as pd
import requests
import re
import jieba
import wordcloud
import matplotlib.pyplot as plt


def run():
    f = open('Danmu.txt', encoding='utf-8').read()
    danmu = jieba.cut(f, cut_all=True)
    danmu_word = jieba.lcut(" ".join(danmu))
    danmu_str = " ".join(danmu_word)
    w = wordcloud.WordCloud(font_path="msyh.ttc",background_color="white",scale=4,max_words=300,max_font_size=60)
    w.generate(danmu_str)
    w.to_file('BiliDanmuWordCloud.png')
    plt.imshow(w, interpolation='bilinear')
    plt.axis("off")
    plt.show()
