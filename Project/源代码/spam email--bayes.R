
################# Naive Bayes classifier for Filtering Spam ##################
##############################################################################


#input data
sms_raw <- read.csv("E:/R试验/短信邮件集合.csv",header=TRUE,stringsAsFactors=FALSE)
sms_raw
# view data: two attributes(type 种类垃圾短信spam，and text也就是属性),5571 messages.
str(sms_raw)

# check type
sms_raw$type <- factor(sms_raw$type)
str(sms_raw$type)
table(sms_raw$type)
prop.table(table(sms_raw$type))#百分数

#clean data in corpus
sms_raw$text[1:3]#前三条信息

# packge "tm" is produced by Vienna University of Economics and Business
#(维也纳财经大学). read the paper: Text mining Infrastructure in R, Feinerer I,
#Hornik K, Meyer D. Journal of Statistics Software, 2008

install.packages("tm")
library(NLP)#自然语言处理
library(tm)

# the first step of precessing text data is to construct a corpus(语料库) 
# that is the set of text file. could be short or long.
# PCorpus() can acess to the corpus saved in database
#文本的处理，形成一个向量

#VectorSource() change sms_raw$text into vector as the parameter of VCorpus() 
#从现有的sms_raw$text 向量创建一个对象，并把它提供给VCorpus()，先对文本创建一个向量，不包含类标号
sms_corpus <- VCorpus(VectorSource(sms_raw$text)) 
print(sms_corpus)

# read messages in the corpus
inspect(sms_corpus[1:2])
as.character(sms_corpus[[1]])


################################## Clean data文本清洗去掉标点符号变小写等等 ###############################

# all the letters are changed to lowercase letters to standardize file
sms_corpus_clean <- tm_map(sms_corpus,tolower)#映射函数
as.character(sms_corpus_clean[[1]])

# remove numbers and stopwords: and,or,until...停用词介词等等 去掉数字
sms_corpus_clean <- tm_map(sms_corpus, removeNumbers)

sms_corpus_clean <- tm_map(sms_corpus_clean, removeWords, stopwords())

# remove punctuations 去掉标点符号
sms_corpus_clean <- tm_map(sms_corpus_clean, removePunctuation)

#stem extracting: 词干提取
install.packages("SnowballC")
library(SnowballC)
wordStem(c("learn","learned","learning","learns"))#示例：执行完之后全是learn
sms_corpus_clean<-tm_map(sms_corpus_clean,stemDocument)

# remove whitespace,only one whitespace between two words
sms_corpus_clean <- tm_map(sms_corpus_clean, stripWhitespace)

inspect(sms_corpus_clean[1:3])
as.character(sms_corpus[1:3])

as.character(sms_corpus_clean[1:3])

################################## prepare data ###############################
# 读入数据生成语料库然后清洗根据语言的特点来，准备数据也就是产生稀疏矩阵creat a sparse matrix--TDM: Term document Matrix ，Split a text document into words
#将文本文档拆分成词语
# tm 包提供了标记短信语料库的功能。将一个语料库作为输入，并创建一个文档-单词稀疏矩阵
# The corpus is used to creat a Term Document Matrix(DTM)
sms_tdm <- DocumentTermMatrix(sms_corpus_clean)#转换形式
inspect(sms_tdm[1:5, 100:105])

#以这几个关键词为查询工具 
d<-c("price","free","call","urgent")#字符型向量，看这几个关键字的情况
sparsematrix<-DocumentTermMatrix(sms_corpus_clean,control=list(dictionary=d))
inspect(sparsematrix)

################################# Creat Word Cloud 词云 ###########################

sms_tdm_train <- sms_tdm[1:4169,]
sms_tdm_test <- sms_tdm[4170:5571,]

# DTM does not contain class lables. So take out attribute type.
sms_train_lables <- sms_raw[1:4169,]$type
sms_test_lables <- sms_raw[4170:5571,]$type
prop.table(table(sms_train_lables ))
prop.table(table(sms_test_lables ))

# word cloud: 词云也可提供一种观察社交诶提网络上热门话题的方式
install.packages("wordcloud")
library(RColorBrewer)
library(wordcloud)

rc=brewer.pal(9,"set1")
wordcloud(sms_corpus_clean, min.freq =70, random.order = FALSE,scale=c(3,0.5))
#  scale: A vector of length 2 indicating the range of the size of the words.#字号的大小范围
#  random.order = FALSE:词云以非随机的顺序排列，出现频率越高的单词越靠近中心
#  min.freq =70：The minimum times of a word appearing in the corpus 单词在语料库中出现的最小次数

# wordcloud of spam messages and non-spam messages
spam <- subset(sms_raw, type == "spam")
ham <- subset(sms_raw, type == "ham")
wordcloud(spam$text, max.words=50, scale=c(3,0.5))
wordcloud(ham$text, min.freq=50, scale=c(3,0.5))
#min.freq	:words with frequency below min.freq will not be plotted
#max.words: Maximum number of words to be plotted. least frequent terms dropped

############## change spars matrix into the structure for bayes classifier  ###########

# Reduce the number of words
sms_freq_words<-findFreqTerms(sms_tdm_train,5) #at leatst 5 times ，这个单词至少出现在5条短信里
str(sms_freq_words)
findFreqTerms(sms_tdm_train,5)

# Testing sets and training sets only contain the words that appear more than 
# or equle to  5 times
sms_tdm_freq_train<-sms_tdm_train[,sms_freq_words]
sms_tdm_freq_test<-sms_tdm_test[,sms_freq_words]

# define a function   NB just know weather the word appear in the message ot not
# NB只想知道这个单词出现了或者没出现，因此需要对矩阵进行转化。
convert_counts<-function(x){x<-ifelse(x>0,"Yes","No")}

# apply convert_counts() to each colum of sparse matrix: 以上函数应用于稀疏矩阵的每一列
# apply() can be used to each row and each colum of a matrix. MARGIN=2 means colum
# MARGIN=1 means row
sms_train<-apply(sms_tdm_freq_train,MARGIN = 2,convert_counts)
sms_test<-apply(sms_tdm_freq_test,MARGIN = 2,convert_counts)
sms_train
# if the word does not appear in the message, use No instad of zero.
# if the word does appears in the message, use Yes instad of frequency.


############################# Creat Bayes Classifier #############################

# Compute the probability that the short message is spam or not 
# based on the existence or non-existence of the word in the message

install.packages("e1071")
library(e1071)
sms_classifier<-naiveBayes(sms_train,sms_train_lables)

#assess the model

sms_test_pred<-predict(sms_classifier,sms_test)
sms_test_pred

install.packages("gmodels")
library(gmodels)
sms_test_lables <- sms_raw[4170:5571,]$type
sms_test_lables
CrossTable(sms_test_pred,sms_test_lables,prop.chisq=FALSE,prop.t=FALSE,dnn=c('predicted','actual'))
#prop.t:表比例是否加入
#prop.chisq:每个单元的卡方值是否加入


#improve model's performance
sms_classifier2<-naiveBayes(sms_train,sms_train_lables,laplace=1)
sms_test_pred2<-predict(sms_classifier2,sms_test)
CrossTable(sms_test_pred2,sms_test_lables,prop.chisq=FALSE,prop.t=FALSE,dnn=c('predicted','actual'))

sms_classifier3<-naiveBayes(sms_train,sms_train_lables,laplace=0.5)
sms_test_pred3<-predict(sms_classifier3,sms_test)
CrossTable(sms_test_pred3,sms_test_lables,prop.chisq=FALSE,prop.t=FALSE,dnn=c('predicted','actual'))
