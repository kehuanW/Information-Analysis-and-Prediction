
# Read data 选取数据所在的路径
BloodData<-read.csv("C:/Users/DELL/Desktop/R语言/Project/源文件/输血服务中心数据集.csv", head = TRUE, encoding = 'utf-8')
BloodData #读取源数据（read命令）并在显示器上显示

##数据结构查看与初步分析
table(BloodData$DonatedBloodInMarch2007) #查看表的属性Donated Blood In March 2007
table(BloodData[,c("Frequency","DonatedBloodInMarch2007")]) #查看两者的关系
par(mfrow=c(1,1)) ##将画板变为1行2列的样式，让两张图在同一行分布
hist(BloodData$Frequency,main = '频数分布',xlab = "Frequency",ylab = "DonatedBloodInMarch2007") #画直方图hist命令

# look at the data structure
str(BloodData)

# We fix the seed so that every time we run the model we do not work with different samples
set.seed(1234)  #初始化随机数发生器

# To construct any classification/regression model, we need to partition
# data into training and testing data 
# We need to randomly select instances for train and test data
# We select approximately 70% of the data for training and 30% for testing

nrow(BloodData) #查看行数S
index = sample(2, nrow(BloodData), replace = TRUE, prob = c(0.7,0.3)) #抽取0.7为训练集，有放回
index
TrainData = BloodData[index == 1, ]
TrainData
nrow(TrainData)
TestData = BloodData[index == 2,]
TestData
nrow(TestData) #划分测试集和训练集

# ******************************* DECISION TREES WITH RPART PACKAGE*******************************************************************************

# Construct a decision tree model using rpart() from "rpart" package
install.packages("rpart") #安装包rpart：基于cart算法的分类回归树模型
library(rpart)

#Telephone_rpart = rpart(DonatedBloodInMarch2007~., data = TrainData,method = "class", control = rpart.control(minsplit = 10, cp = 0))
rpart.model = rpart(DonatedBloodInMarch2007~., data = TrainData,method = "class",parms = list(split="information")) #default
rpart.model
# In "control" we can control the pruning options. 
# To learn about the settings of rpart.control, use help (write "?rpart.control" in console)

# TO plot rpart decision tree we can either use rpart.plot() function from rpart.plot package or fancyRpartPlot() function from "rattle" package.
install.packages("rpart.plot")
library(rpart.plot) #--- If the packages rattle is installed, it has rpart.plot in it
rpart.plot(rpart.model)#画出决策树了
# or 
#install.packages("rattle")
#library(rattle)
#fancyRpartPlot(rpart.model)

#Predict the probablity
(predict(rpart.model))
?predict #?查看帮助

# Look at the two-way table to check the performance of the mdoel on train data
# Check Predicted Class for TrainData
train_predict=predict(rpart.model, type = "class")  
train_predict
is.factor(train_predict)
#Check Actual Class for TrainData
BloodData$DonatedBloodInMarch2007
#or
train.predict=cbind(TrainData,train_predict) #把两个结果合起来看
train.predict

#Compare Predicted vs Actual：confusion matrix 产生混淆矩阵
(train_confusion=table(train_predict, TrainData$DonatedBloodInMarch2007, dnn = c("Predicted", "Actual"))) 
# dnn adds the label for rows and columns
# dnn stands for dimension names

(Erorr.train=(sum(train_confusion)-sum(diag(train_confusion)))/sum(train_confusion)) #计算错误率，一棵树完成

# predict testing data
test_predict=predict(rpart.model,newdata = TestData,type="class")
test_predict
(test_confusion=table(test_predict, TestData$DonatedBloodInMarch2007, dnn = c("Predicted", "Actual")))
#or
#(test_confusion=table(actural=TestData$流失,predictedclass=test_predict))

(Erorr.rpart=(sum(test_confusion)-sum(diag(test_confusion)))/sum(test_confusion))

install.packages("ipred") 
install.packages("lattice")
install.packages("ggplot2")
library(lattice)
library(ggplot2)
library(caret)
train_predict<-as.factor(train_predict)
is.factor(TrainData$DonatedBloodInMarch2007)
TrainData$DonatedBloodInMarch2007<-as.factor(TrainData$DonatedBloodInMarch2007)
TestData$DonatedBloodInMarch2007<-as.factor(TestData$DonatedBloodInMarch2007)
sensitivity(train_predict,TrainData$DonatedBloodInMarch2007)
specificity(train_predict,TrainData$DonatedBloodInMarch2007)
sensitivity(test_predict,TestData$DonatedBloodInMarch2007)
specificity(test_predict,TestData$DonatedBloodInMarch2007)

# show CP parameters for the tree pruning
?printcp
printcp(rpart.model)
plotcp(rpart.model)

# we want to prune the tree 
set.seed(1234)
rpart.prune<-prune(rpart.model,cp=0.03)
rpart.plot(rpart.prune) #剪枝

# Summary of predictions on test data and training data by the pruned tree
train.predict<-predict(rpart.prune,type="class")# default data is training data
train.predict
#test.predict<-predict(rpart.prune,newdata = TestData) #default is probability
test.predict<-predict(rpart.prune,newdata = TestData,type="class")
test.predict

(test_confusion=table(actural=TestData$DonatedBloodInMarch2007,predictedclass=test_predict))
(Erorr.rpart=(sum(test_confusion)-sum(diag(test_confusion)))/sum(test_confusion))

#train.predict=as.vector(train.predict)
sensitivity(train.predict,TrainData$DonatedBloodInMarch2007)
specificity(train.predict,TrainData$DonatedBloodInMarch2007)
sensitivity(test.predict,TestData$DonatedBloodInMarch2007)
specificity(test.predict,TestData$DonatedBloodInMarch2007)

#we can use the model to classify new data
predict(rpart.prune, TestData)

#*******************ROC***************************************
#*************************************************************
install.packages("ROCR")
library(ROCR)

#type is default means type="prob"
train.predict<-predict(rpart.prune)
test.predict<-predict(rpart.prune,newdata = TestData) 
#
train.pred = prediction(train.predict[,2],TrainData$DonatedBloodInMarch2007) 
test.pred<-prediction(test.predict[,2],TestData$DonatedBloodInMarch2007)

#use performance() to compute tpr and  fpr，needing return value of prediction()
train.perf<-performance(train.pred,"tpr","fpr")  
test.perf<-performance(test.pred,"tpr","fpr")  

plot(train.perf,main="ROC Curve",col = "blue", lty = 1, lwd = 3) #得到roc曲线 蓝线训练集
par(new=T)#defaulting to FALSE.如果设定为TRUE，
#If set to TRUE, the next plotting should not clean the current
plot(test.perf,main="ROC Curve",col = "red", lty = 1, lwd = 3) #画图函数plot 得到红线测试集
#lty = 3, lwd = 3 线型，宽度
#Add straight lines to a plot (a = intercept and b = slope)
abline(a= 0, b=1)
legend("bottomright",legend=c("training","testing"),bty="n",lty=c(1,1),col=c("blue","red"))

# ***************************************** Gain Chart ****************************************** #
train.gain = performance(train.pred, "tpr", "rpp")
test.gain<-performance(test.pred,"tpr","rpp")  

plot(train.gain,main="Gain Chart",col="blue",lty = 1, lwd = 3)
par(new=T)
plot(test.gain,main="Gain chart",col = "red", lty = 1, lwd = 3)
abline(a= 0, b=1)
legend("bottomright",legend=c("training","testing"),bty="n",lty=c(1,1),col=c("blue","red"))

# **************************************** Lift Chart ******************************************** #
train.lift = performance(train.pred, "lift", "rpp")
test.lift<-performance(test.pred,"lift","rpp")  

plot(train.lift,main="Lift Curve",col="blue",lty = 1, lwd = 3)
par(new=T)
plot(test.lift,col = "red", lty = 1, lwd = 3)
legend("bottomright",legend=c("training","testing"),bty="n",lty=c(1,1),col=c("blue","red"))

# ************ DECISION TREES WITH C50 PACKAGE*************************
install.packages("C50")
install.packages("e1071")
install.packages("irr")
install.packages("lpSolve")
install.packages("vcd")
library(C50)
library(caret)
library(irr)
library(lpSolve)
library(vcd)
library(grid)

#typical decision tree with C5.0
set.seed(123)
train_sample<-sample(1000,900) # randomly select 900 samples
train<-TelephoneData[train_sample,]
test<-TelephoneData[-train_sample,]
typical.model<-C5.0(train[,-15],as.factor(train$DonatedBloodInMarch2007)) ##训练数据框要删除分类因子向量
typical.pred<-predict(typical.model,test)
typical.confusion=table(typical.pred,test$DonatedBloodInMarch2007,dnn = c("Predicted", "Actual"))
(Erorr.typical=(sum(typical.confusion)-sum(diag(typical.confusion)))/sum(typical.confusion))

# with boosting in C5.0()
##trials：模型的迭代次数,以10个独立决策树组合为例,winnow ：在建模之前是否对变量进行特征选择
#CF：剪枝时的置信度
boost.model<-C5.0(train[,-15],as.factor(train$DonatedBloodInMarch2007),trials=10,control=C5.0,Control(winnow = TRUE,CF=0.25)) 
summary(boost.model)
boost.pred<-predict(boost.model,test)
boost.confusion=table(boost.pred,test$DonatedBloodInMarch2007,dnn = c("Predicted", "Actual"))
(Erorr.typical=(sum(boost.confusion)-sum(diag(boost.confusion)))/sum(boost.confusion))


# Cross Validate and compute Kappa
set.seed(12)
folds<-createFolds(TelephoneData$DonatedBloodInMarch2007,k=10) #根据training的laber-流失把数据集切分成10等份
cv.result<-lapply(folds,function(x){
  trainset<-TelephoneData[-x,]
  testset<-TelephoneData[x,]
  model<-C5.0(as.factor(trainset$DonatedBloodInMarch2007)~.,data=trainset[,-15])
  pred<-predict(model,testset)
  actual<-testset$DonatedBloodInMarch2007
  Kappa<-Kappa(table(actual,pred))
  return(Kappa)
 })
str(cv.result)
mean(unlist(cv.result))

plot(model)


# ******************************* DECISION TREES WITH PARTY PACKAGE*******************************************************************************

# construct a decision tree using ctree() from "party" package
install.packages("party")
library(party)
set.seed(123)
train_sample<-sample(1000,900) # randomly select 900 samples
train<-TelephoneData[train_sample,]
test<-TelephoneData[-train_sample,]
# Basic model
ctree.model<-ctree(DonatedBloodInMarch2007~.,data=train)
plot(ctree.model)
plot(ctree.model,type="simple")

# Summary of predictions on test data 
ctree.predict=predict(ctree.model,newdata=test,type="response")
ctree.predict
(ctree.confusion=table(ctree.predict, test$DonatedBloodInMarch2007, dnn = c("Predicted", "Actual")))
#or
(test_confusion=table(actural=test$DonatedBloodInMarch2007,ctree.predict))
(Erorr.ctree=(sum(test_confusion)-sum(diag(test_confusion)))/sum(test_confusion))
#
#install.packages("gmodels")
#library(gmodels)
#ctree.confusion=CrossTable(test$流失,ctree.predict,prop.chisq=FALSE,prop.c=FALSE,prop.r=FALSE,dnn=c('actual','predicted'))


# new DATA

# Predict the "probability" (instead of classes) of prediction for test data
predict(ctree.model, newdata = newData, type = "prob")
# The predict function here returns the probablity of predictied value (With what probability or predictions are correct (it is known as confidence))

