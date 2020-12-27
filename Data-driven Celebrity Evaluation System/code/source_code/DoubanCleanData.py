#!/usr/bin/env python
# coding: utf-8

# In[9]:


import requests
from requests.exceptions import RequestException
from bs4 import BeautifulSoup
import bs4
import csv
import re
import time
import random

import csv
import numpy as np
import pandas as pd
from pandas import Series,DataFrame
import sys

def run():
    a1 = pd.read_csv('DoubanRawData.csv', header=0, names=['Rate', 'Date', 'Comment', 'Like'])

    columns = ['Rate', 'Comment', 'Like', 'Date']

    a1.to_csv('DoubanCleanData.csv', index=False, encoding='utf-8-sig', columns=columns)

    print("Douban Clean Data crawled successfully")





