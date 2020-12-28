
##################################################################################
#  R语言中关于神经网络的包（package）：nnet、AMORE、neuralnet等。                #
#  nnet提供了最常见的前馈反向传播神经网络算法。                                  #
#  neuralnet包的改进在于提供了弹性反向传播算法和更多的激活函数形式。             #
#  AMORE包则更进一步提供了更为丰富的控制参数，并可以增加多个隐藏层。             #
##################################################################################

######################################热水器数据####################################
#要了解用户使用家用电器的习惯，必须采集用户使用电器的相关数据。在热水器用户行为分析中，
#用水事件识别是重要的环节。某热水器生产厂商欲分析用户的用水行为特征，本数据集用于在划
#分好的一次完整用水事件中，识别出洗浴事件。

##############################AMORE package##########################

install.packages("AMORE")
library(AMORE)

# read data
data<-read.csv("C:/Users/dell/Learning/3.1/信息分析与预测/实验5 ANN/german_credit.csv", head = TRUE)
apply(data,2,function(x) sum(is.na(x))) #列进行检验,如果数据没有缺失值，则每个属性下的值都为0

# change to numeric data 把1dao20列都转换成数值型
for (i in 1:20){ data[,i]<-as.numeric(as.vector(data)[,i])}
data

# 归一化处理
#normalize<-function(x){(x-min(x)/(max(x)-min(x)))}
#data<-as.data.frame(lapply(Iris, normalize))

# 划分训练数据集以及测试数据集
sub<-sample(1:nrow(data),round(nrow(data)*1/2))
length(sub)
german_train<-data[sub,]#取1/2的数据做训练集
german_test<-data[-sub,]#取1/2的数据做测试集

# 设定输入层输出层
inputdata=german_train[,1:19] #1-4列作为输入
outputdata=german_train[,20] #第5列作为输出

# 创建多层前馈神经网络 
n.neurons=c(19,8,2,1) #输入列1-4列是19个属性，2个隐藏层8，2（可以改动），输出层1个
net=newff(n.neurons,learning.rate.global = 1e-2,momentum.global = 0.5,error.criterium = "LMS",hidden.layer = "tansig",output.layer ="purelin",method="ADAPTgdwm") #sigmoid函数可以换其他purelin， 追溯下降法
#最小均方算法,Least-Mean-Square,LMS
result=train(net,inputdata,outputdata,error.criterium="LMS",report=TRUE,show.step=100,n.shows=5) #循环100*5次

#save BP network to hard disk
save(result,file="E:/teaching....") #可以存 也可以不存，引号里是保存的路径

#test the model
set.seed(12345)

targetoutput=german_test[,20]
testdata=german_test[,1:19]
#if save the model to hard disk
#load(netfile)

output=sim(result$net,testdata)#仿真得到输出结果 simulate
output[which(output<1.5)]<-1
output[which(output>=1.5)]<-2

#comput accuracy 计算精确度
sum=0
for(i in 1:nrow(german_test)){
  if(output[i]==targetoutput[i])   #Ol
    sum=sum+1
}
sum
cat("正确率",sum/nrow(german_test)) #nrow获取行数，得到正确率

########################### neuralnet package##########################

install.packages("neuralnet")
library(neuralnet)

#read data
Iris<-read.table(file="C:/Users/dell/Learning/3.1/信息分析与预测/实验5 ANN/Iris.txt",header=TRUE,sep=",")
#划分训练集和测试集
ind = sample(2,nrow(iris),replace = TRUE,prob = c(0.7,0.3))
trainset = iris[ind == 1,]
testset = iris[ind == 2,]

#根据数据集在Class列取值不同，为训练集新增三种数列
trainset$setosa = trainset$Species == "setosa" 
trainset$virginica = trainset$Species == "virginica" 
trainset$versicolor = trainset$Species == "versicolor"



########################### neuralnet package##########################

install.packages("neuralnet")
library(neuralnet)

#read data
Iris<-read.table(file="C:/Users/dell/Learning/3.1/信息分析与预测/实验5 ANN/Iris.txt",header=TRUE,sep=",")
#划分训练集和测试集
ind = sample(2,nrow(iris),replace = TRUE,prob = c(0.7,0.3))
trainset = iris[ind == 1,]
testset = iris[ind == 2,]

#根据数据集在Class列取值不同，为训练集新增三种数列
trainset$setosa = trainset$Species == "setosa" 
trainset$virginica = trainset$Species == "virginica" 
trainset$versicolor = trainset$Species == "versicolor"

#######################neurealnet建立神经网络#####################
#model 调用neuralnet函数创建一个包括3个隐藏层的神经网络，训练结果有可能随机发生变化，所以得到的结果可能不同。
set.seed(12345)
(BPnet1<-neuralnet(versicolor + virginica + setosa ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,trainset,hidden = 3))
#attension: can not write: Purchase~.,data=......
BPnet1$result.matrix   #weights and other information
BPnet1$weights  #array that stores weights
BPnet1$response

#######################网络及权值参数可视化#####################
plot(BPnet1)

#####################输入变量重要性及可视化#####################
#variabes' importance
head(BPnet1$generalized.weights[[1]])
par(mfrow=c(1,1))
gwplot(BPnet1,selected.covariate="Sepal.Length")
gwplot(BPnet1,selected.covariate="Sepal.Width")
gwplot(BPnet1,selected.covariate="Petal.Length") 
gwplot(BPnet1,selected.covariate="Petal.Width")#gwplot箱线图
#we found Age is the least important.gwplot() is the function in the package of neuralnet.


#####################不同输入变量水平组合下的预测#####################
#Effects of different combinations on output
(mean(Buy$Age))
newdata<-matrix(c(39,1,1,39,1,2,39,1,3,39,2,1,39,2,2,39,2,3),nrow=6,ncol=3,byrow=TRUE)
newdata
new.output<-compute(BPnet1,covariate=newdata)
new.output$net.result
#femal with middle and low income has higher puchase probability.




###########################nnet package建立二分类神经网络###############################

install.packages("nnet")
library("nnet")
set.seed(12345)

BPnet2<-nnet(Species ~ .,data = trainset,size = 2,rang = 0.1,decay = 5e-4,maxit = 200)
summary(BPnet2)
iris.predict=predict(BPnet2,testset,type="class")


#####???
library("neuralnet")
set.seed(1000)
(BPnet3<-neuralnet(versicolor + virginica + setosa ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,data=trainset,
                   algorithm="backprop",learningrate=0.01,hidden=2,err.fct="sse",linear.output=FALSE))

plot(BPnet3)

#if probability greater than 50 % then 1 else 0
nn1 = ifelse(BPnet3$net.result[[1]]>0.5,1,0)

(misClasificationError = mean(trainset$Species!=nn1))






