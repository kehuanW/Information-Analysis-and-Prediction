
import jieba


# In[156]:


from wordcloud import WordCloud


# In[157]:


import matplotlib.pyplot as plt

def run():
    f = open('DoubanComment.txt', 'r', encoding='utf-8').read()
    wordlist = jieba.cut(f, cut_all=True)
    w1 = " ".join(wordlist)
    stop_words = ['就是', '但是', '一部', '这部', '少年', '这种', '觉得', '什么', '电影', '的','n']
    wc = WordCloud(background_color="white", scale=4, max_words=300, max_font_size=60, stopwords=stop_words,
                   font_path='C:/simhei.ttf')
    wc.generate(w1)
    wc.to_file('DoubanCommentWordCloud.png')
    plt.imshow(wc, interpolation='bilinear')
    plt.axis("off")
    plt.show()
