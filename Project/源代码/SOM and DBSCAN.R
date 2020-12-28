
################################# Kohonen and DBSCAN ############################
#################################################################################

#############iris#################
library("kohonen")
set.seed(123)
data(iris)
irisdata<-iris[,-5]     #输入变量
# biaozhun化处理bin构建模型
irisdata.som <- som(scale(irisdata), grid = somgrid(xdim=1, ydim=3, topo="rectangular"),rlen=200)
#邻域半径默认为获胜节点与最远节点距离的2/3
summary(irisdata.som)
mean(irisdata.som$distances)# distance 各观测与各自簇质心的距离，距离越近，越合理。
irisdata.som$code #各输出节点$的连接权值
table(irisdata.som$unit.classif)  # unit.classif#各观测所属聚类类别编号


#plot
plot(irisdata.som,type="mapping",pchs=irisdata.som$unit.classif,col=c("red"),main="SOM 网络输出层示意图")
#mapping 可视化输出层，各输出节点以不同符号的点表示观测点与簇对应关系。
#各簇内密度的粗略表现。
plot(irisdata.som,type="changes",main="SOM 网络聚类评价图")
#changes迭代过程中各质心位置偏移的平均值，簇的质心随迭代周期变化的折线图

plot(irisdata.som,type="counts",main="SOM聚类样本量分布情况")
#颜色深浅表示簇所含样本的多少
plot(irisdata.som,type="quality",main="SOM聚类类内差异情况图")
#可视化输出层，深浅表示簇内观测与质心距离的平均值大小。 平均值小，效果好。
#比mapping更精确


################ DBSCAN聚类示例
Data<irisdata
install.packages("fpc")
library("fpc")
par(mfrow=c(2,3))
plot(Data,cex=0.5,main="观测点的分布图")
(DBS1<-dbscan(data=Data,eps=0.2,MinPts=200,scale = FALSE)) 
plot(DBS1,Data,cex=0.5,main="DBSCAN聚类(eps=0.2,MinPts=200)")
(DBS2<-dbscan(data=Data,eps=0.5,MinPts=80,scale = FALSE)) 
plot(DBS2,Data,cex=0.5,main="DBSCAN聚类(eps=0.5,MinPts=80)")
(DBS3<-dbscan(data=Data,eps=0.2,MinPts=100,scale = FALSE))
plot(DBS3,Data,cex=0.5,main="DBSCAN聚类(eps=0.2,MinPts=100)")
(DBS4<-dbscan(data=Data,eps=0.5,MinPts=300,scale = FALSE))
plot(DBS4,Data,cex=0.5,main="DBSCAN聚类(eps=0.5,MinPts=300)")
(DBS5<-dbscan(data=Data,eps=0.2,MinPts=30,scale = FALSE))
plot(DBS5,Data,cex=0.5,main="DBSCAN聚类(eps=0.2,MinPts=30)")





