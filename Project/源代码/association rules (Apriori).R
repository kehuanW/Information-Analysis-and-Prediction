################################### Association Rules###########################
################################################################################

install.packages("arules")
install.packages("arulesViz")
library("arules")
library("arulesViz")
install.packages("mclust")

###########事务表生成transactoins对象：方式一

(MyList<-list(c("A","C","D"),c("B","C","E"),c("A","B","C","E"),c("B","E")))

names(MyList)<-paste("Tr",c(1:4),sep="")
MyTrans<-as(MyList,"transactions")
MyTrans
summary(MyTrans)
inspect(MyTrans)
image(MyTrans)

###########事实表生成transactoins对象：方式二
MyFact<-matrix(c(
  1,0,1,1,0,
  0,1,1,0,1,
  1,1,1,0,1,
  0,1,0,0,1
),nrow=4,ncol=5,byrow=TRUE)
#给矩阵添加行列名称
dimnames(MyFact)<-list(paste("Tr",c(1:4), sep = ""),c("A","B","C","D","E"))
MyFact
(MyTrans<-as(MyFact,"transactions"))
(as(MyTrans,"data.frame"))

###########数据以事务表形式组织在数据框中，生成transactoins对象：方式三
MyT<-data.frame(
  TID=c(1,1,1,2,2,2,3,3,3,3,4,4), 
  items=c("A","C","D","B","C","E","A","B","C","E","B","E")
)
(MyList<-split(MyT[,"items"],MyT[,"TID"]))
(MyTrans<-as(MyList,"transactions"))

###########数据文件生成transactoins对象：方式四
#MyTrans<-read.transactions(file="事务原始数据.txt",format="basket",sep=",")
#MyTrans<-read.transactions(file="事务表数据.txt",format="single",cols=c("TID","ITEMS"),sep="	")

##！！注意：read.transactions不支持对事实表的读取

################挖掘购物篮数据的关联规则####################

#read file. header=true 文本文件第一行是标题，数据用，分开
data.txt<-read.table(file="E:/R试验/购物篮数据.txt",header=TRUE,sep=",")
data.txt
#delete column 1 to 7  只看买的东西之间的
data.apriori<-as.matrix(data.txt[,-(1:7)])
data.apriori
#R 支持事实表和事务表，进行转换。
data.trans<-as(data.apriori,"transactions")
summary(data.trans)
##results 
#sizes
#0   1   2   3   4   5   6   7   8 
#60 174 227 220 175  81  38  21   4 

# get rules
rules.apriori<-apriori(data.trans,parameter=list(support=0.1,confidence=0.5,target="rules"))
summary(rules.apriori)
inspect(rules.apriori)

# 排序
inspect(sort(x=rules.apriori,by="support",decreasing=TRUE))#排序 
inspect(sort(x=rules.apriori,by="lift",decreasing=TRUE))
inspect(subset(x=rules.apriori,subset=rhs%in%"beer"&lift>=2.2))
#rule<-subset(model,subset=rhs%in%"whole milk"&lift>=2.2)
#inspect(rule)
#要求结果中，被关联项是beer 同时lift值要大于2.2
# %in%是精确匹配
# %pin%是部分匹配，也就是说只要item like '%A%' or item like '%B%'
# %ain%是完全匹配，也就是说itemset has ’A' and itemset has ‘B'
# 同时可以通过 条件运算符(&, |, !) 添加 support, confidence, lift的过滤条件。
inspect(subset(x=rules.apriori,subset=rhs%in%"beer"&lift>=2.2))
inspect(subset(x=rules.apriori,subset=size(rules.apriori)==2))

#可视化频繁项集

Freitemset.apriori<-apriori(data.trans,parameter=list(support=0.1,confidence=0.5,target="frequent itemsets"))
plot(x=Freitemset.apriori,method="graph",control=list(main="频繁项集可视化"))

#可视化规则

rules.apriori<-apriori(data.trans,parameter=list(support=0.1,confidence=0.5,target="rules"))
plot(x=rules.apriori,method="graph",control=list(main="关联规则可视化"))
plot(x=rules.apriori,method="paracoord",control=list(main="关联规则可视化"))

#顾客选择性倾向对比:不同年龄、不同性别、购买啤酒同时出现的可能性

mydata<-read.table(file="E:/R试验/购物篮数据.txt",header=TRUE,sep=",")

str(mydata)
data.rule<-mydata[,c(4,7,14)]#提取sex，age,beer
data.rule
data.rule[,2]<-sapply(data.rule[,2],FUN=function(x){
  if(x %in% 0:29) x<-1 else
  if(x %in% 30:49) x<-2 else
  if(x %in% 50:59) x<-3  })
data.rule
data.rule$age<-factor(data.rule$age)
data.rule$beer<-factor(data.rule$beer)
transaction<-as(data.rule,"transactions")
rules<-apriori(data=transaction,parameter=list(support=0.01,confidence=0.2,minlen=2,
                                             target="rules"  ),appearance = list(rhs=c("beer=1"),
                                            lhs=c("age=1","age=2","age=3","sex=M","sex=F"),default="none"))
inspect(rules)

realrules<-subset(x=rules,subset=quality(rules)$lift>1)
#get the rules whose lift is more than 1
plot(realrules,method="graph",control=list(arrowSize=2,main="性别年龄与啤酒的倾向性描述"))

