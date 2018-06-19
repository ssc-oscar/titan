library(randomForest)
load("rfmodelsCr.RData")  
library(data.table)
x=fread("4096_out/NNN.txt",sep=";",quote="",header=FALSE);
names(x) = c("n0","o0","n1","o1","n","e","ln","fn","un", "ifn", "d2vSim");
pr0 = predict(rfCr,x);
fwrite(data.frame(n0=x[,"n0"],"o0"=x[,"o0"],n1=x[,"n1"],o1=x[,"o1"],pr=pr0),file="4096_out/NNN.p",sep=";")


