suppressMessages(library(pbdMPI,quietly = TRUE))
suppressMessages(library(pbdDMAT,quietly = TRUE))
suppressMessages(library(pbdIO,quietly = TRUE))
x = comm.fread ("auth", pattern="*",quote="",sep=",")
dx = dim(x);
comm.print(dx, all.rank=TRUE)


