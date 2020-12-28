
########################  Bagging  ##################
library(ipred)
library(rpart)#baggin函数“内嵌”模型是分类树，其参数control应为rpart函数的参数
set.seed(1234)

BloodData<-read.csv("C:/Users/DELL/Desktop/R语言/Project/源文件/输血服务中心数据集.csv", head = TRUE)

##one tree
ctrl<-rpart.control(minisplit=20,maxcompete=4, maxdepth=30,cp=0.01,xval=10)
onemodel<-rpart(DonatedBloodInMarch2007~., data=BloodData, method="class", parms=list(split="gini"))
pred<-predict(onemodel, BloodData, type="class")
pred
(confusion.one<-table(BloodData$DonatedBloodInMarch2007,pred))
(err1=(sum(confusion.one)-sum(diag(confusion.one)))/sum(confusion.one))

## bagging
BloodData$DonatedBloodInMarch2007<-as.factor(BloodData$DonatedBloodInMarch2007) #bagging要求变量类型为因子factor
bagmodel<-bagging(DonatedBloodInMarch2007~., data=BloodData,nbagg=25,coob=TRUE, control=ctrl)
bagmodel
library(rpart)
detach("package:rpart")
bag.pred<-predict(bagmodel,BloodData[,1:4],type="class")
bag.pred=as.factor(bag.pred)
bag.pred
(confusion.bag<-table(bag.pred,BloodData$DonatedBloodInMarch2007))
(err2=(sum(confusion.bag)-sum(diag(confusion.bag)))/sum(confusion.bag))

######################  AdaBoosting ####################################
install.packages("adabag")
library(foreach)
library(doParallel)
library(iterators)
library(parallel)
library(adabag)
ctrl<-rpart.control(minisplit=10,maxcompete=4, maxdepth=30,cp=0.01,xval=10)
set.seed(1234)
BloodData$DonatedBloodInMarch2007<-as.factor(BloodData$DonatedBloodInMarch2007)
BoostModel<-boosting(DonatedBloodInMarch2007~., data=BloodData,boos=TRUE,mfinal=10,coeflearn = "Breiman",control = ctrl)
pre.boost<-predict(BoostModel,BloodData)
(confusion.boost<-pre.boost$confusion)  #混淆矩阵存放在一个叫confusion 的子对象中
(error.boost<-(sum(confusion.boost)-sum(diag(confusion.boost)))/sum(confusion.boost))

# input variabes' importance
barplot(BoostModel$imp[order(BoostModel$imp, decreasing = TRUE)], ylim = c(0, 100), main = "Variables Relative Importance", col = "lightblue")
# ylim()，xlim  set coordinate axis


# ten fold validation
boostcvModel <- boosting.cv(DonatedBloodInMarch2007 ~ ., v = 10, data = BloodData, mfinal = 10, control = ctrl)
boostcvModel$confusion

###################### randomForest ######################################

install.packages("randomForest")
library(randomForest)
set.seed(1234)
#randomforesModel<-randomForest(DonatedBloodInMarch2007~., data=BloodData,important=TRUE,proximity=TRUE,mtry=k(k is m),ntree=400(size of forest))
randomforesModel<-randomForest(DonatedBloodInMarch2007~., data=BloodData,important=TRUE,proximity=TRUE)
head(randomforesModel$votes) #predicted probability list of observations
head(randomforesModel$oob.times)#各观测作为oob的次数
Draw<-par()
par(mfrow=c(2,1),mar=c(5,5,3,1))
plot(randomforesModel,main="随机森林OOB错判率和决策树棵数")
#plot( )的绘图数据是err.rate.黑色线是整体判错率，红色线是对NO类预测的错判率，
#绿色线是对YES类预测的判错率。模型对No类的预测效果好于Yes类和整体。

plot(margin(randomforesModel),type="h",main="边界点",xlab="观测序列",ylab="比率差")
#margin（）考察处于边界附近的点和盘错情况
#附近的点的定义依据：投票给正确类别（该观测说属的实际类别）的树的比率-
#                    投票给众数类（除正确类别以外的其他众数类别）的树的比率
#之差为正表示预测正确，为负表示预测错误，差的绝对值越小，越接近于零，表明该观测处在分类边界上

head(treesize(randomforesModel))#浏览各个树的叶节点个数

par(Draw)
pre.random<-predict(randomforesModel,BloodData)
(confusion.random<-table(BloodData$DonatedBloodInMarch2007,pre.random))
(error.random<-(sum(confusion.random)-sum(diag(confusion.random)))/sum(confusion.random))#计算错误率

importance(randomforesModel)# type可以是1，也可以是2， 计算gini系数
#用于判别计算变量重要性的方法，1表示使用精度平均较少值作为度量标准；
#2表示采用节点不纯度的平均减少值最为度量标准。值越大说明变量的重要性越强；
par(mfrow=c(1,1))
barplot(randomforesModel$importance[,1],main="输入变量重要性测度(预测精度变化)指标柱形图")
box() #黑框
varImpPlot(randomforesModel,main="输入变量重要性测度散点图",cex=0.7)  #cex字体大小
randomforesModel$importance
is.matrix(randomforesModel$importance)

####find the best value of mtry.
#默认情况下数据集变量个数的二次方根（分类模型）或三分之一（预测模型）。
n=length(names(BloodData))
set.seed(100)
for(i in 1:(n-1)){mtryFit<-randomForest(DonatedBloodInMarch2007~.,data=BloodData,mtry=i)
   err=mean(mtryFit$err.rate)
   print(err)}
    
#**************************ROC  Bagging***************************
#*********************************************************

library(ROCR)
(bag.predict<-predict(bagmodel,type="prob"))
bag.pred = prediction(bag.predict[,2],BloodData$DonatedBloodInMarch2007) 

#use performance() to compute tpr and  fpr，needing return value of prediction()
bag.perf<-performance(bag.pred,"tpr","fpr")  
test.perf<-performance(test.pred,"tpr","fpr")

plot(bag.perf,main="ROC Curve",col = "blue", lty = 1, lwd = 3)
abline(a= 0, b=1)


#**************************ROC  Boosting***************************
#*********************************************************
boosting.pred = prediction(pre.boost$prob[,2],BloodData$DonatedBloodInMarch2007) 

#use performance() to compute tpr and  fpr，needing return value of prediction()
boosting.perf<-performance(boosting.pred,"tpr","fpr")  
par(new=T)
plot(boosting.perf,main="ROC Curve",col = "red", lty = 1, lwd = 3)

    
#**************************ROC Random Forest***************************
#*********************************************************
(pre.random<-predict(randomforesModel,BloodData,type="prob"))

random.pred = prediction(pre.random[,2],BloodData$DonatedBloodInMarch2007) 

#use performance() to compute tpr and  fpr，needing return value of prediction()
random.perf<-performance(random.pred,"tpr","fpr")  
par(new=T)
plot(random.perf,main="ROC Curve",col = "green", lty = 1, lwd = 3)
legend("bottomright",legend=c("bagging","adaboosting","random"),bty="n",lty=c(1,1),col=c("blue","red","green"))    

