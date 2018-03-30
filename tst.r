suppressMessages(library(pbdMPI,quietly = TRUE))
suppressMessages(library(pbdDMAT,quietly = TRUE))
suppressMessages(library(pbdIO,quietly = TRUE))
x = comm.fread ("auth", pattern="*",quote="",sep=",")
#dx = dim(x);
#comm.print(dx, all.rank=TRUE)
.libPaths('./R/x86_64-pc-linux-gnu-library/3.3')
suppressMessages(library('RecordLinkage', lib.loc="./R/x86_64-pc-linux-gnu-library/3.3", quietly = TRUE))


#tandem.webdev,Agence-Tandem,Agence-Tandem,Agence-Tandem,tandem.webdev@gmail.com,Agence-Tandem <tandem.webdev@gmail.com>
names(x) = c("un","n","fn","ln","e","a");

pairs = compare.linkage (
x[,c("n", "e", "ln", "fn", "un", "a")],
x[,c("n", "e", "ln", "fn", "un", "a")],
                       exclude=c(6),strcmp=c(1:5),strcmpfun = jarowinkler);




