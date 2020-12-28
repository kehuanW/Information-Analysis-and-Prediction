#############linear separabe线性###############

set.seed(12345)
#首先构建数据集，创建一个服从正态分布的矩阵，先产生一个矩阵
x<-matrix(rnorm(n=40*2,mean=0,sd=1),ncol=2,byrow=TRUE)
x
y<-c(rep(-1,20),rep(1,20))#-1重复20次，1重复20次，rep=replicate
y
x[y==1,]<-x[y==1,]+1.5# 对后二十个观测值加上1.5
data_train<-data.frame(Fx1=x[,1],Fx2=x[,2],Fy=as.factor(y))  #traning data
data_train
#生成训练样本集,前二十个观测标签为-1，后二十个位+1

#testing data
x<-matrix(rnorm(n=20,mean=0,sd=1),ncol=2,byrow=TRUE)
x
y<-sample(x=c(-1,1),size=10,replace=TRUE)
y
x[y==1,]<-x[y==1,]+1.5
x
data_test<-data.frame(Fx1=x[,1],Fx2=x[,2],Fy=as.factor(y)) 
data_test

#画出数据集的情况
plot(data_train[,1:2],col=as.integer(as.vector(data_train[,3]))+3,pch=7,cex=0.7,main="训练样本集-1和+1类散点图")
#data_train ，3第三列y 第三列+3，是不同的颜色，pch是形状*，

#构建支持向量机
library("e1071")
SvmFit<-svm(Fy~.,data=data_train,type="C-classification",kernel="linear",cost=10,scale=FALSE) #此处使用的核函数为linear（高斯）核函数cost可以改，根据分类结果
summary(SvmFit)
SvmFit$index #给出SV的编号，可能每个人都不一样
plot(x=SvmFit,data=data_train,formula=Fx1~Fx2,svSymbol="#",dataSymbol="*",grid=100)
SvmFit<-svm(Fy~.,data=data_train,type="C-classification",kernel="linear",cost=0.1,scale=FALSE)
summary(SvmFit)
#Number of Support Vectors:  25在这个模型中支持向量的数目是25  gamma: 取值 0.5 
#预测值为正说明模型判断样本点属于类别1，为负说明属于类别0，且数值绝对值越大说明预测可靠性越大

##############10 folds validation to choose C 利用10折交叉验证找到预测误差最小时的损失惩罚参数###############

set.seed(12345)
tObj<-tune.svm(Fy~.,data=data_train,type="C-classification",kernel="linear",
  cost=c(0.001,0.01,0.1,1,5,10,100,1000),scale=FALSE)
summary(tObj)
BestSvm<-tObj$best.model
summary(BestSvm)

plot(x=BestSvm,data=data_train,formula=Fx1~Fx2,svSymbol="$",dataSymbol="*",grid=100)#等高线
plot(x=BestSvm,data=data_train,formula=Fx1~Fx2,svSymbol="$",dataSymbol="*")

yPred<-predict(BestSvm,data_test)
(ConfM<-table(yPred,data_test$Fy))
(Err<-(sum(ConfM)-sum(diag(ConfM)))/sum(ConfM))

############## non linear separable 非线性############# 

set.seed(12345)
x<-matrix(rnorm(n=400,mean=0,sd=1),ncol=2,byrow=TRUE)
x[1:100,]<-x[1:100,]+2
x[101:150,]<-x[101:150,]-2
y<-c(rep(1,150),rep(2,50))
y
data<-data.frame(Fx1=x[,1],Fx2=x[,2],Fy=as.factor(y))
data
flag<-sample(1:200,size=100)
data_train<-data[flag,]
data_test<-data[-flag,]
plot(data_train[,1:2],col=as.integer(as.vector(data_train[,3])),pch=8,cex=0.7,main="训练样本集散点图")
library("e1071")
set.seed(12345)
tObj<-tune.svm(Fy~.,data=data_train,type="C-classification",kernel="radial",
  cost=c(0.001,0.01,0.1,1,5,10,100,1000),gamma=c(0.5,1,2,3,4),scale=FALSE)   #gamma太大容易过度拟合
plot(tObj,xlab=expression(gamma),ylab="损失惩罚参数C",
  main="不同参数组合下的预测错误率",nlevels=10,color.palette=terrain.colors)

summary(tObj)
BestSvm<-tObj$best.model
summary(BestSvm)
plot(x=BestSvm,data=data_train,formula=Fx1~Fx2,svSymbol="#",dataSymbol="*",grid=100)
plot(x=BestSvm,data=data_train,formula=Fx1~Fx2,svSymbol="#",dataSymbol="*")
yPred<-predict(BestSvm,data_test)
(ConfM<-table(yPred,data_test$Fy))
(Err<-(sum(ConfM)-sum(diag(ConfM)))/sum(ConfM)) #准确度


############## multiple catagory 模拟多分类的支持向量分类################

#在线性不可分的原则下，随机生成训练样本集；其中，输入变量有2个，输出变量有0,1和2三类。
set.seed(12345)
x<-matrix(rnorm(n=400,mean=0,sd=1),ncol=2,byrow=TRUE)
x[1:100,]<-x[1:100,]+2
x[101:150,]<-x[101:150,]-2
x<-rbind(x,matrix(rnorm(n=100,mean=0,sd=1),ncol=2,byrow=TRUE))
y<-c(rep(1,150),rep(2,50))
y<-c(y,rep(0,50))
x[y==0,2]<-x[y==0,2]+3
data<-data.frame(Fx1=x[,1],Fx2=x[,2],Fy=as.factor(y))
plot(data[,2:1],col=as.integer(as.vector(data[,3]))+4,pch=6,cex=0.7,main="训练样本集散点图")

library("e1071")
set.seed(12345)
tObj<-tune.svm(Fy~.,data=data,type="C-classification",kernel="radial",
  cost=c(0.001,0.01,0.1,1,5,10,100,1000),gamma=c(0.5,1,2,3,4),scale=FALSE)
BestSvm<-tObj$best.model
summary(BestSvm)
plot(x=BestSvm,data=data,formula=Fx1~Fx2,svSymbol="#",dataSymbol="*",grid=100)
SvmFit<-svm(Fy~.,data=data,type="C-classification",kernel="radial",cost=5,gamma=1,scale=FALSE)

#查看各观测点的决策函数值
head(SvmFit$decision.values)

yPred<-predict(SvmFit,data)
(ConfM<-table(yPred,data$Fy))
(Err<-(sum(ConfM)-sum(diag(ConfM)))/sum(ConfM))

################### e1071 binary classes##################


BloodData<-read.csv("C:/Users/dell/Learning/3.1/信息分析与预测/实验7 SVM/输血服务中心数据集.csv", head = TRUE)
BloodData$DonatedBloodInMarch2007<-as.factor(BloodData$DonatedBloodInMarch2007)

# 划分训练数据集以及测试数据集
sub<-sample(1:nrow(BloodData),round(nrow(BloodData)*2/3))
length(sub)
Blood_train<-BloodData[sub,]#取2/3的数据做训练集
Blood_test<-BloodData[-sub,]#取1/3的数据做测试集
#################################################
plot(Blood_train[,3:4],col=as.integer(as.vector(data_train[,3]))+4,pch=5,cex=0.7,main="散点图")

set.seed(12345)
library("e1071")
tObj<-tune.svm(DonatedBloodInMarch2007~.,data=Blood_train,type="C-classification",kernel="radial",gamma=10^(-6:-3),cost=10^(-3:2))
plot(tObj,xlab=expression(gamma),ylab="损失惩罚参数C",
     main="不同参数组合下的预测错误率",nlevels=10,color.palette=terrain.colors)
BestSvm<-tObj$best.model
summary(BestSvm)


yPred<-predict(BestSvm,Blood_test)
(ConfM<-table(yPred,Blood_test$DonatedBloodInMarch2007))
(Err<-(sum(ConfM)-sum(diag(ConfM)))/sum(ConfM))


