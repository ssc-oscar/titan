suppressMessages(library(pbdMPI,quietly = TRUE))
suppressMessages(library(pbdIO,quietly = TRUE))
.libPaths('./R/x86_64-pc-linux-gnu-library/3.3')
suppressMessages(library('data.table', quietly = TRUE))
suppressMessages(library('RecordLinkage', lib.loc="./R/x86_64-pc-linux-gnu-library/3.3", quietly = TRUE))

FR = 21;
TO = 320;

init()
#Rprof(append = TRUE)
ptm <- proc.time()

myrank=comm.rank();
fnamev=paste("4096_21-320/outV",myrank,sep=".");
ncom = comm.size();
nc = ceiling(ncom/2);

x = comm.fread ("auth4096", pattern="*",readers=256, quote="",sep=";",header=F)
barrier()
comm.print("read all");
x = pbdIO:::comm.rebalance.df(x);
barrier()
comm.print("rebalanced all");

names(x) = c("un","n","fn","ln","e","a");
fwrite(x[,c("a","un")], file=paste("4096_21-320/outL",myrank,sep="."), sep=";",col.names=FALSE,quote=FALSE,append=F);
barrier()
dif = proc.time() - ptm;
comm.print(dif);
comm.print("Wrote labels");

x =  x[,c("n", "e", "ln", "fn", "un", "fn","a")];
x$rank=myrank;
#x1 = x[,c("n", "e", "ln", "fn", "un", "ln","a","rank")];
names(x)=c("n", "e", "ln", "fn", "un", "ifn","a","rank");
#names(x1)=c("n", "e", "ln", "fn", "un", "ifn","a","rank");


if (FR == 0){
  x1 = x[,c("n", "e", "ln", "fn", "un", "ln","a","rank")];
  names(x1)=c("n", "e", "ln", "fn", "un", "ifn","a","rank");
  pairs = compare.linkage (x, x1, exclude=c(7,8),strcmp=c(1:6),strcmpfun = jarowinkler);
  dif = proc.time() - ptm;
  comm.print(dif);
  str = paste("Computed self pairs for rank", myrank, paste(dif,collapse=""));
  comm.print(str);
  #fwrite(pairs$data1[,c("a","un")],file=paste("4096_21-320/outL1",myrank,sep="."), sep=";",col.names=FALSE,quote=FALSE,append=F); 
  #barrier()
  #predict and write out matches
  MM=apply(pairs$pairs[,c("n", "e", "ln", "fn", "un", "ifn")],1,max, na.rm = T)>.8&pairs$pairs$id1 != pairs$pairs$id2;
  val = c();
  ll = sum(MM);
  if (ll > 0){
    p = pairs$pairs[MM,-9];
    str = c(ll,dim(p));
    comm.print(str)
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

message.pass <- function(off, rnk) {
 otherrank <- (rnk+off) %% ncom;
 # Send a message to the partner
 comm.print(paste("passed to ",c(rnk,otherrank)));#,all.rank=TRUE)
 isend (x[,c("n", "e", "ln", "fn", "un", "ln","a","rank")], rank.dest=otherrank);
}

message.get <- function(off, rnk) {
 otherrank <- (rnk-off) %% ncom;
 # Receive the message
 comm.print(paste("about to rcv ", paste(rnk,otherrank)))
 irecv(rank.source=otherrank);
 #irecv();
}

for (i in max(1,FR):min(TO,nc)){
  otherrankP <- (myrank+i) %% ncom;
  isend (x[,c("n", "e", "ln", "fn", "un", "ln","a","rank")], rank.dest=otherrankP);
  otherrankR <- (myrank-i) %% ncom;
  x2 = irecv(rank.source=otherrankR);
  #message.pass (i, myrank);
  #x2 = message.get (i, myrank);
  names(x2)=c("n", "e", "ln", "fn", "un", "ifn","a","rank");
  pairs = compare.linkage (x, x2, exclude=c(7,8),strcmp=c(1:6),strcmpfun = jarowinkler);
  MM=apply(pairs$pairs[,c("n", "e", "ln", "fn", "un", "ifn")],1,max,na.rm = T)>.8;
  ll = sum(MM);
  p = pairs$pairs[MM,-9];
  if (ll > 0){
     a = rep(myrank,ll);
     b = rep(otherrankR, ll);
     #val0 = cbind (a, b, p);
     p$a=a;
     p$b=b;
     #p$of = i;
     #p$a1 = pairs$data1[p$id1,"a"]
     #p$a2 = pairs$data2[p$id2,"a"]
     #p$a2r = pairs$data2[p$id2,"rank"]
     #val = rbind(val, val0);
     fwrite(p,file=fnamev, sep=";",quote=FALSE,append=T);
  }
  comm.print(c(ll,dim(p),otherrankR));
  #barrier();
}

barrier ();
comm.print ("Finished computing");
pbdMPI::finalize()
