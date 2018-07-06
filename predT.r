suppressMessages(library(pbdMPI,quietly = TRUE))
suppressMessages(library(pbdIO,quietly = TRUE))
.libPaths('./R/x86_64-pc-linux-gnu-library/3.3')
suppressMessages(library('data.table', quietly = TRUE))
suppressMessages(library(randomForest))
load("rfCr2.RData")  
init()
#Rprof(append = TRUE)
#ptm <- proc.time()

myrank=comm.rank();
fnamev=paste("4096_tout/NNN",myrank,sep=".");
ncom = comm.size();
nc = ceiling(ncom/2);

x = comm.fread ("4096_out", pattern="NNN.txt",readers=16, quote="",sep=";",header=F)
barrier()
x = pbdIO:::comm.rebalance.df(x);

x[is.na(x)]=0;
names(x) = c("n0","o0","n1","o1","n","e","ln","fn","un", "ifn","fnf","lnf","unf", "d2vSim");
pr0 = predict(rfCr2,x);
sel = pr0==1
x = x[sel,c("n0","o0","n1","o1","n","e","ln","fn","un", "ifn","fnf","lnf","unf", "d2vSim")];
fwrite(x,file=fnamev,sep=";");
pbdMPI::finalize();

