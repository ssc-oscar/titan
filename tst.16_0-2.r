suppressMessages(library(pbdMPI,quietly = TRUE))
suppressMessages(library(pbdDMAT,quietly = TRUE))
suppressMessages(library(pbdIO,quietly = TRUE))
.libPaths('./R/x86_64-pc-linux-gnu-library/3.3')
suppressMessages(library('data.table', quietly = TRUE))
suppressMessages(library('RecordLinkage', lib.loc="./R/x86_64-pc-linux-gnu-library/3.3", quietly = TRUE))

FR = 0;
TO = 2;

init()
#Rprof(append = TRUE)

x = comm.fread ("auth1", pattern="*",quote="",sep=";",header=F)
names(x) = c("un","n","fn","ln","e","a");
x =  x[,c("n", "e", "ln", "fn", "un", "fn","a")];
x1 = x[,c("n", "e", "ln", "fn", "un", "ln","a")];
names(x)=c("n", "e", "ln", "fn", "un", "ifn","a")
names(x1)=c("n", "e", "ln", "fn", "un", "ifn","a")
#dx = dim(x);
#comm.print(dx, all.rank=TRUE)

barrier()
comm.print("read all");

#xf <- do.call('rbind',allgather(x))
#dxf = dim(xf);
#comm.print(dxf, all.rank=TRUE)

#tandem.webdev,Agence-Tandem,Agence-Tandem,Agence-Tandem,tandem.webdev@gmail.com,Agence-Tandem <tandem.webdev@gmail.com>
myrank=comm.rank();
fnamev=paste("16_0-2/outV",myrank,sep=".");


if (FR == 0){
  pairs = compare.linkage (x, x1, exclude=c(7),strcmp=c(1:6),strcmpfun = jarowinkler);
  barrier()
  comm.print("Computed self pairs");
  #predict and write out matches
  MM=apply(pairs$pairs[,c("n", "e", "ln", "fn", "un", "ifn")],1,max, na.rm = T)>.8&pairs$pairs$id1 != pairs$pairs$id2;
  val = c();
  ll = sum(MM);
  if (ll > 0){
    p = pairs$pairs[MM,-7];
    comm.print(c(ll,dim(p)))
    a = rep(myrank,ll);
    b = a;
    val = cbind(a, b, p);
    fwrite(data.frame(val),file=fnamev, sep=";",quote=FALSE,append=T);
    rm(val)
  }
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
  p = pairs$pairs[MM,-7];
  comm.print(c(ll,dim(p)));
  if (ll > 0){
     orank = (myrank-i)%%ncom;
     a = rep(myrank,ll);
     b = rep(orank, ll);
     val0 = cbind (a, b, p);
     #val = rbind(val, val0);
     fwrite(data.frame(val0),file=fnamev, sep=";",quote=FALSE,append=T);
  }
}

#comm.print(lbl[1:10,], all.rank=TRUE)
barrier();
comm.print("Finished computing");
##fnamel=paste("outL",myrank,sep=".");
##fwrite(data.frame(lbl),file=fnamel, sep=";",quote=FALSE);
#fnamev=paste("outV",myrank,sep=".");
#fwrite(data.frame(val),file=fnamev, sep=";",quote=FALSE);
barrier();
#finalize();
