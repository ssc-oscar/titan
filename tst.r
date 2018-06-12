suppressMessages(library(pbdMPI,quietly = TRUE))
suppressMessages(library(pbdDMAT,quietly = TRUE))
suppressMessages(library(pbdIO,quietly = TRUE))
.libPaths('./R/x86_64-pc-linux-gnu-library/3.3')
suppressMessages(library('data.table', quietly = TRUE))
suppressMessages(library('RecordLinkage', lib.loc="./R/x86_64-pc-linux-gnu-library/3.3", quietly = TRUE))

FR = __FROM__;
TO = __TO__;

init()
#Rprof(append = TRUE)
myrank=comm.rank();
fnamev=paste("__OUT__/outV",myrank,sep=".");

#source("rebal.r");
x = comm.fread ("auth1", pattern="*",readers=__READERS__, quote="",sep=";",header=F)
barrier()
comm.print("read all");
x = pbdIO:::comm.rebalance.df(x);
barrier()
comm.print("rebalanced all");

names(x) = c("un","n","fn","ln","e","a");
fwrite(x[,c("a","un")], file=paste("__OUT__/outL",myrank,sep="."), sep=";",header=F,quote=FALSE,append=F);
barrier()
comm.print("Wrote labels");

x =  x[,c("n", "e", "ln", "fn", "un", "fn","a")];
x1 = x[,c("n", "e", "ln", "fn", "un", "ln","a")];
names(x)=c("n", "e", "ln", "fn", "un", "ifn","a")
names(x1)=c("n", "e", "ln", "fn", "un", "ifn","a")
#dx = dim(x);
#comm.print(dx, all.rank=TRUE)

#xf <- do.call('rbind',allgather(x))
#dxf = dim(xf);
#comm.print(dxf, all.rank=TRUE)

#tandem.webdev,Agence-Tandem,Agence-Tandem,Agence-Tandem,tandem.webdev@gmail.com,Agence-Tandem <tandem.webdev@gmail.com>


if (FR == 0){
  pairs = compare.linkage (x, x1, exclude=c(7),strcmp=c(1:6),strcmpfun = jarowinkler);
  comm.print(paste("Computed self pairs for rank", myrank));
  #barrier()
  #predict and write out matches
  MM=apply(pairs$pairs[,c("n", "e", "ln", "fn", "un", "ifn")],1,max, na.rm = T)>.8&pairs$pairs$id1 != pairs$pairs$id2;
  val = c();
  ll = sum(MM);
  if (ll > 0){
    p = pairs$pairs[MM,-9];
    comm.print(c(ll,dim(p)))
    a = rep(myrank,ll);
    b = a;
    p$a = a;
    p$b = b
    #val = data.frame(cbind(a, b, p));
    fwrite(p,file=fnamev, sep=";",quote=FALSE,append=T);
    rm(val)
  }
  comm.print(paste("Wrote self pairs for rank", myrank));
}

message.pass <- function(off=1) {
 myrank <- comm.rank()
 otherrank <- (myrank+off) %% comm.size()
 # Send a message to the partner
 #comm.print(paste("passed to ",c(myrank,otherrank)),all.rank=TRUE)
 isend (x1[,c("n", "e", "ln", "fn", "un", "ifn","a")], rank.dest=otherrank);
}

message.get <- function(off=1) {
 myrank <- comm.rank();
 otherrank <- (myrank-off) %% comm.size();
 # Receive the message
 comm.print(paste("about to rcv ", paste(myrank,otherrank)))
 irecv(rank.source=otherrank);
}
ncom = comm.size();
nc = ceiling(comm.size()/2);

for (i in max(1,FR):min(TO,nc)){
  message.pass(i);
  x1=message.get(i);
  pairs = compare.linkage (x, x1, exclude=c(7),strcmp=c(1:6),strcmpfun = jarowinkler);
  MM=apply(pairs$pairs[,c("n", "e", "ln", "fn", "un", "ifn")],1,max,na.rm = T)>.8;
  ll = sum(MM);
  p = pairs$pairs[MM,-9];
  if (ll > 0){
     orank = (myrank-i)%%ncom;
     a = rep(myrank,ll);
     b = rep(orank, ll);
     #val0 = cbind (a, b, p);
     p$a=a;
     p$b=b;
     #val = rbind(val, val0);
     fwrite(p,file=fnamev, sep=";",quote=FALSE,append=T);
  }
  comm.print(c(ll,dim(p)));
}

#comm.print(lbl[1:10,], all.rank=TRUE)
barrier ();
comm.print ("Finished computing");
##fnamel=paste("outL",myrank,sep=".");
##fwrite(data.frame(lbl),file=fnamel, sep=";",quote=FALSE);
#fnamev=paste("outV",myrank,sep=".");
#fwrite(data.frame(val),file=fnamev, sep=";",quote=FALSE);
#barrier();
#finalize();
