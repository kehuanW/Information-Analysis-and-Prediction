
#########################K-Means for Simulated Data##########################
##########################################################################

set.seed(12345)
x<-matrix(rnorm(n=100,mean=0,sd=1),ncol=2,byrow=TRUE)  ##随机产生正态分布的的点
x[1:25,1]<-x[1:25,1]+3           
x[1:25,2]<-x[1:25,2]-4
par(mfrow=c(2,2))
plot(x,main="样本观测点的分布",xlab="",ylab="") 

## 2 clusters
set.seed(12345)
(KMClu1<-kmeans(x=x,centers=2,nstart=1))  
plot(x,col=(KMClu1$cluster+1),main="K-Means聚类K=2",xlab="",ylab="",pch=20,cex=1.5)##每一个簇的均值点
points(KMClu1$centers,pch=3)

##4 clusters with nstart=1
set.seed(12345)
KMClu2<-kmeans(x=x,centers=4,nstart=1)   
plot(x,col=(KMClu2$cluster+1),main="K-Means聚类K=4,nstart=1",xlab="",ylab="",pch=20,cex=1.5)
points(KMClu2$centers,pch=3)

## 4 ckusters with nstart=30
KMClu1$betweenss/(2-1)/(KMClu1$tot.withinss/(50-2))
KMClu2$betweenss/(4-1)/(KMClu2$tot.withinss/(50-4))##取k为几比较合适
set.seed(12345)
KMClu2<-kmeans(x=x,centers=4,nstart=30)
plot(x,col=(KMClu2$cluster+1),main="K-Means聚类K=4,nstart=30",xlab="",ylab="",pch=20,cex=1.5)
points(KMClu2$centers,pch=3)

##################### K-Meansfor Actual Data #############################

PoData<-read.table(file="C:/Users/DELL/Desktop/R试验/聚类kmeans/环境污染数据.txt",header=TRUE)
PoData
CluData<-PoData[,2:7]

set.seed(12345)
CluR<-kmeans(x=CluData,centers=4,iter.max=10,nstart=30)
CluR$size##每一个类中有几个值
CluR$centers##四个均值点

###########Visulization of K-Means 

par(mfrow=c(2,1))
PoData$CluR<-CluR$cluster# save the result of clustering to PoData$CluR
plot(PoData$CluR,pch=PoData$CluR,ylab="类别编号",xlab="省市",main="聚类的类成员",axes=FALSE)##pch不同的符号
# pch：绘图符号设置参数，用4,19,2,6代表的符号绘图不同的簇

par(las=2)#las只能是0,1,2,3中的某一个值，用于表示刻度值的方向。0表示总是平行于坐标轴；
##1表示总是水平方向；2表示总是垂直于坐标轴；3表示总是垂直方向。#
axis(1,at=1:31,labels=PoData$province,cex.axis=0.6)
axis(2,at=1:4,labels=1:4,cex.axis=0.6)
box()
legend("topright",c("第一类","第二类","第三类","第四类"),pch=c(4,19,2,6),cex=0.6)

###########K-Means聚类特征的可视化##每一个类均值点的变化
plot(CluR$centers[1,],type="l",ylim=c(0,82),xlab="聚类变量",ylab="组均值(类质心)",main="各类聚类变量均值的变化折线图",axes=FALSE)
axis(1,at=1:6,labels=c("生活污水排放量","生活二氧化硫排放量","生活烟尘排放量","工业固体废物排放量","工业废气排放总量","工业废水排放量"),cex.axis=0.6)
box()
lines(1:6,CluR$centers[2,],lty=2,col=2)
lines(1:6,CluR$centers[3,],lty=3,col=3)
lines(1:6,CluR$centers[4,],lty=4,col=4)
legend("topleft",c("第一类","第二类","第三类","第四类"),lty=1:4,col=1:4,cex=0.6)

###########K-Means聚类效果的可视化评价
CluR$betweenss/CluR$totss*100##两两之间的关系
par(mfrow=c(2,3))
plot(PoData[,c(2,3)],col=PoData$CluR,main="生活污染情况",xlab="生活污水排放量",ylab="生活二氧化硫排放量")
points(CluR$centers[,c(1,2)],col=rownames(CluR$centers),pch=8,cex=2)
plot(PoData[,c(2,4)],col=PoData$CluR,main="生活污染情况",xlab="生活污水排放量",ylab="生活烟尘排放量")
points(CluR$centers[,c(1,3)],col=rownames(CluR$centers),pch=8,cex=2)
plot(PoData[,c(3,4)],col=PoData$CluR,main="生活污染情况",xlab="生活二氧化硫排放量",ylab="生活烟尘排放量")
points(CluR$centers[,c(2,3)],col=rownames(CluR$centers),pch=8,cex=2)

plot(PoData[,c(5,6)],col=PoData$CluR,main="工业污染情况",xlab="工业固体废物排放量",ylab="工业废气排放总量")
points(CluR$centers[,c(4,5)],col=rownames(CluR$centers),pch=8,cex=2)
plot(PoData[,c(5,7)],col=PoData$CluR,main="工业污染情况",xlab="工业固体废物排放量",ylab="工业废水排放量")
points(CluR$centers[,c(4,6)],col=rownames(CluR$centers),pch=8,cex=2)
plot(PoData[,c(6,7)],col=PoData$CluR,main="工业污染情况",xlab="工业废气排放总量",ylab="工业废水排放量")
points(CluR$centers[,c(5,6)],col=rownames(CluR$centers),pch=8,cex=2)


############################层次聚类#################################
#####################################################################
PoData<-read.table(file="C:/Users/DELL/Desktop/R试验/聚类kmeans/环境污染数据.txt",header=TRUE)
CluData<-PoData[,2:7]
DisMatrix<-dist(CluData,method="euclidean")##距离矩阵欧几里得距离
CluR<-hclust(d=DisMatrix,method="ward.D")##计算距离

###############层次聚类的树形图
par(mfrow=c(2,1))
plot(CluR,labels=PoData[,1])
box()
###########层次聚类的碎石图
plot(CluR$height,30:1,type="b",cex=0.7,xlab="距离测度",ylab="聚类数目")

######取4类的聚类解并可视化

PoData$memb<-cutree(CluR,k=4) #聚成4个簇，最小的类间距离的变化幅度不大
table(PoData$memb)
plot(PoData$memb,pch=PoData$memb,ylab="类别编号",xlab="省市",main="聚类的类成员",axes=FALSE)
par(las=2)
axis(1,at=1:31,labels=PoData$province,cex.axis=0.6)
axis(2,at=1:4,labels=1:4,cex.axis=0.6)
box()

data(iris)
iris



