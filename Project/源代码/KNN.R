#################################Classification of Iris ############################
install.packages("class")
library(class)

# Read data 
Iris_train<-read.table(file="C:/Users/dell/Learning/3.1/信息分析与预测/实验3/Iris-Train.txt",header=TRUE,sep=",")
Iris_train #显示数据
head(Iris_train) 
str(Iris_train)
round(prop.table(table(Iris_train$ IrisPlantClass))*100,digits = 1) #统计1和0的个数，求概率，小数点保留一位
Iris_test<-read.table(file="C:/Users/dell/Learning/3.1/信息分析与预测/实验3/Iris-Train.txt",header=TRUE,sep=",")
round(prop.table(table(Iris_test$ IrisPlantClass))*100,digits = 1) #小数点保留一位
Iris_train.lable<-Iris_train[,5] #判断列
Iris_test.lable<-Iris_test[,5] 
# nomalization: min-max 归一化
normalize<-function(x) {return((x-min(x))/(max(x)-min(x)))}
#test the function 测试一下把下面归一是啥样
normalize(c(1,2,3,4,5)) 
# 把normaize()函数应用到数据框wbcdde di 2~31列，并把产生的结果列表转化成数据框。
(Iris_train.n<-as.data.frame(lapply(Iris_train[1:4],normalize)))
summary(Iris_train.n)
(Iris_test.n<-as.data.frame(lapply(Iris_test[1:4],normalize)))
summary(Iris_test.n)


Iris_train.lable<-as.factor(Iris_train.lable) #把离散量转换为factor因子
Iris_test.lable<-as.factor(Iris_test.lable)

set.seed(123456) #随机数
errRatio<-vector()   
for(i in 1:30){    #k从1到30，最终选择错误率最小的k
  KnnFit<-knn(train=Iris_train.n,test=Iris_test.n,cl=Iris_train.lable,k=i,prob=FALSE) 
  CT<-table(Iris_test.lable,KnnFit)   #产生CT即混淆矩阵
  errRatio<-c(errRatio,(1-sum(diag(CT))/sum(CT))*100)  #求错误率   
}
errRatio
plot(errRatio,type="b",xlab="近邻个数K",ylab="错判率(%)",main="鸢尾植物分类预测中的近邻数K与错判率")

#for new data
#KnnFit<-knn(train=Tmall_train.n,test=Tmall_new.n,cl=Tmall_train.lable,k=9,prob=FALSE)

#model by caret package
install.packages("lattice")
install.packages("e1071")
install.packages("ggplot2")#自己加的
install.packages("caret")
library(caret)
library(e1071)
set.seed(123456)
trainFit<-train(x=Iris_train.n,y=Iris_train.lable,method="knn") 

#model by caret package #调用kknn函数进行模型训练与预测
install.packages("kknn")
library(kknn)
set.seed(123456)
kknnFit1<-kknn(IrisPlantClass~.,Iris_train,test=Iris_train,k=7) 
kknnFit2<-kknn(IrisPlantClass~.,Iris_train,test=Iris_test,k=7) 
summary(kknnFit1)
fit <- fitted(kknnFit1)
table(Iris_test$ IrisPlantClass, fit)#查看结果

################鸢尾植物分类数据KNN分类讨论变量重要性#####################

library("class")  
set.seed(123456)
errRatio<-vector()

# Determine parameter K
for(i in 1:30){
  KnnFit<-knn(train=Iris_train[,-5],test=Iris_test[,-5],cl=Iris_train[,5],k=i,prob=FALSE) 
  CT<-table(Iris_test[,5],KnnFit) 
  errRatio<-c(errRatio,(1-sum(diag(CT))/sum(CT))*100)    
}
plot(errRatio,type="l",xlab="近邻个数K",ylab="错判率(%)",main="近邻数K与错判率")
errRatio
(errDelteX<-errRatio[7])

# find variable importance
for(i in -1:-4){
  fit<-knn(train=Iris_train[,c(-5,i)],test=Iris_test[,c(-5,i)],cl=Iris_train[,5],k=6)
  CT<-table(Iris_test[,5],fit)
  errDelteX<-c(errDelteX,(1-sum(diag(CT))/sum(CT))*100) 
  #error rate with all variables, error rate without each varable
}
CT
errDelteX
plot(errDelteX,type="l",xlab="剔除变量",ylab="剔除错判率(%)",main="剔除变量与错判率(K=7)",cex.main=0.8)
xTitle=c("1:全体变量","2:萼片长度","3:萼片宽度","4:花瓣长度","5:花瓣宽度") #加上图例：类名
legend("topright",legend=xTitle,title="变量说明",lty=1,cex=0.6)   

FI<-errDelteX[-1]+1/4 #the first row of errDeltex is the error rate with all variables. FI=e+1/p 权值计算 
wi<-FI/sum(FI)  # standardize  归一化   
wi

#Concatenate vectors after converting to character. 向量转换成字符并连接
GLabs<-paste(c("萼片长度","萼片宽度","花瓣长度","花瓣宽度"),round(wi,2),sep=":") 

pie(wi,labels=GLabs,clockwise=TRUE,main="输入变量权重",cex.main=0.8) #饼图
par(mfrow=c(1,1))#自己加的 画板变成一行一列
ColPch=as.vector(as.numeric(Iris_test[,5]))+2 #+1 2 3都可以 代表的符号不一样 ！！！我真的是天才！
plot(Iris_test[,c(1,4)],pch=ColPch,cex=0.7,xlim=c(4,9),ylim=c(0,3),col=ColPch,
     xlab="萼片长度",ylab="花瓣宽度",main="二维特征空间中的观测",cex.main=0.8)


#################天猫数据加权KNN分类##############################

install.packages("kknn")
library("kknn")

Iris_train<-read.table(file="C:/Users/dell/Learning/3.1/信息分析与预测/实验3/Iris-Train.txt",header=TRUE,sep=",")
Iris_train$IrisPlantClass<-as.factor(Iris_train$IrisPlantClass)

fit<-train.kknn(formula=IrisPlantClass~.,data=Iris_train,kmax=11,distance=2,kernel=c("rectangular","triangular","gaussian"),na.action=na.omit())
#na.action=na.omit()表示带有缺失值的观测不参加分析

plot(fit$MISCLASS[,1]*100,type="l",main="不同核函数和近邻个数K下的错判率曲线图",cex.main=0.8,xlab="近邻个数K",ylab="错判率(%)")

#matrix: kmax*n. 存放不同核函数下当近邻个数K依次取1至kmax时，分类预测的留一法判错率

lines(fit$MISCLASS[,2]*100,lty=2,col=1)
lines(fit$MISCLASS[,3]*100,lty=3,col=2)
legend("topleft",legend=c("rectangular","triangular","gaussian"),lty=c(1,2,3),col=c(1,1,2),cex=0.7)   #给出图例

###加权KNN

Iris_test<-read.table(file="C:/Users/dell/Learning/3.1/信息分析与预测/实验3/Iris-Text.txt",header=TRUE,sep=",")
Iris_test$IrisPlantClass<-as.factor(Iris_test$IrisPlantClass)
fit<-kknn(formula=IrisPlantClass~.,train=Iris_train,test=Iris_test,k=7,distance=2,kernel="gaussian",na.action=na.omit())
(CT<-table(Iris_test[,5],fit$fitted.values))
#fitted.values:近邻K依次取1至kmax时，各个观测的预测类别
(errRatio<-(1-sum(diag(CT))/sum(CT))*100)

###柱状图比较

library("class")
fit<-knn(train=Iris_train.n,test=Iris_test.n,cl=Iris_train.lable,k=7) #??
CT<-table(Iris_test[,5],fit)
errRatio<-c(errRatio,(1-sum(diag(CT))/sum(CT))*100)
errGraph<-barplot(errRatio,main="加权K近邻法与K近邻法的错判率对比图(K=7)",cex.main=0.8,xlab="分类方法",ylab="错判率(%)",axes=FALSE)#barplot柱状图
axis(side=1,at=c(0,errGraph,3),labels=c("","加权K-近邻法","K-近邻法",""),tcl=0.25)
axis(side=2,tcl=0.4)