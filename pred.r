library(randomForest)
load("rfmodelsCr.RData")  
library(data.table)
x=fread("4096_out/NNN.txt",sep=";",quote="",header=FALSE);
x[is.na(x)]=0;
names(x) = c("n0","o0","n1","o1","n","e","ln","fn","un", "ifn", "d2vSim");
pr0 = predict(rfCr,x);
sel = pr0==1
x = x[sel,c("n0","o0","n1","o1")];
fwrite(x,file="4096_out/NNN.p",sep=";")


