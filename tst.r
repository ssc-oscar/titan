suppressMessages(library(pbdMPI,quietly = TRUE))
suppressMessages(library(pbdDMAT,quietly = TRUE))
suppressMessages(library(pbdIO,quietly = TRUE))
.libPaths('./R/x86_64-pc-linux-gnu-library/3.3')
suppressMessages(library('data.table', quietly = TRUE))
suppressMessages(library('RecordLinkage', lib.loc="./R/x86_64-pc-linux-gnu-library/3.3", quietly = TRUE))

#init.grid()

x = comm.fread ("auth1", pattern="*",quote="",sep=",")
names(x) = c("un","n","fn","ln","e","a");
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
#

pairs = compare.linkage (x, x1, exclude=c(7),strcmp=c(1:6),strcmpfun = jarowinkler);
#predict and write out matches
lbl0 = paste(pairs$data1[pairs$pairs$id1,7], pairs$data2[pairs$pairs$id2,7], sep="||")
#comm.print(lbl0[1:2], all.rank=TRUE)

lbl = c()
val = c()
for (id in 1:dim(pairs$data1)[1]){
  lbli = c();
  vali = c();
  for (j in 1:6){
    mm = pairs$pairs$id1 == id;
    val0 = pairs$pairs[mm,2+j];
    oo = order(val0,decreasing=T);
    lbli = cbind(lbli,lbl0[mm][oo][1:50]);
    #if (j==5) comm.print(lbli[1:2,], all.rank=TRUE)
    vali = cbind(vali, val0[oo][1:50]);
  }
  lbl = rbind(lbl, lbli);
  val = rbind(val, vali);
}


#dd1 = dim(lbl);
#comm.print(dd1, all.rank=TRUE)


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
nc = ceiling(comm.size()-1);
for (i in 1:nc){
  message.pass(i);
  x1=message.get(i);
  pairs = compare.linkage (x, x1, exclude=c(7),strcmp=c(1:6),strcmpfun = jarowinkler);
  lbl1 = paste(pairs$data1[pairs$pairs$id1,7], pairs$data2[pairs$pairs$id2,7], sep="||");
  for (id in 1:dim(pairs$data1)[1]){
    mm = pairs$pairs$id1 == id;
    mm0 = (1:50)+(id-1)*50;
    for (j in 1:6){
      val1 = pairs$pairs [mm,2+j];
      val0 = val [mm0, j];
      oo = order(c(val0,val1),decreasing=T);
      lbl[mm0,j] = c(lbl[mm0,j],lbl1[mm])[oo][1:50];
      val [mm0, j] = c(val0,val1)[oo][1:50];
    }
  }
  #predict and write out matches
}

#comm.print(lbl[1:10,], all.rank=TRUE)
barrier();
myrank=comm.rank();
fnamel=paste("outL",myrank,sep=".");
fwrite(data.frame(lbl),file=fnamel, sep=";",quote=FALSE);
fnamev=paste("outV",myrank,sep=".");
fwrite(data.frame(val),file=fnamev, sep=";",quote=FALSE);
barrier();
#finalize();
