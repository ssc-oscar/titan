# Pairwise similarity at scale using pbdR

```
ssh titan
mkdir -p ~/csc344/proj-shared/id
cd ~/csc344/proj-shared/id
rm -rf .git
git clone gh:ssc-oscar/titan .
cc -O3 -o jwt jarowinklerm.c 
module load r/3.3.2x
echo 'install.packages(c("ff", "fastmatch", "bit", "ffbase", "e1071", "lava", "prodlim","ada", "ipred", "evd", "RecordLinkage"), lib=".")' | R --no-save

#get a complete list of author strings for data version N
scp -p da0:/data/basemaps/gz/asN.s .

#prepare text features for comparison
zcat asN.s |  grep -v '^$'| perl -I /da3_data/lookup/ -I ~/lib64/perl5 -ane 'use cmt;use Compress::LZF;chop();$a=$_;@x=git_signature_parse($a); $fn=$x[0];$ln=$x[0];$fn=~s/\s.*//;$ln=~s/\s*$//;$ln=~s/.*\s//;$u=$x[1];$u=~s/\@.*//;print "$u;$x[0];$fn;$ln;$x[1];$a\n"' | gzip > asfeaturesN.gz
```

Try 4096 nodes, just two iterations
```
n=4096
fr=0
to=1
p=$(($n/16))
mkdir auth$n
head -2000000 asfeaturesN > asfeaturesN2M
split -n r/$n asfeaturesN2M auth$n/a.
mkdir ${n}_${fr}-$to
sed "s/__OUT__/${n}_${fr}-$to/;s/__FROM__/$fr/;s/__TO__/$to/;s/auth1/auth$n/;s/__READERS__/$p/" tst.r > tst.${n}_${fr}-$to.r
sed "s/tst.r/tst.${n}_${fr}-$to.r/;s/walltime=02:00/walltime=00:30/;s/nodes=2/nodes=$p/;s/THREADS=32/THREADS=$n/" r.pbs > r${n}_${fr}-$to.pbs
qsub r${n}_${fr}-$to.pbs

```

# Below is the code used fot EMSE paper
```
ssh titan
cd     csc229/scratch/audris1/id
```

the files may be removed
```
rm -rf .git
git clone gh:ssc-oscar/titan .
cc -O3 -o jwt jarowinklerm.c 
scp -p da4:/data/update/cprojects.as1 .
```

the locally installed modules may be removed
```
module load r/3.3.2x
R --no-save
install.packages(c("ff", "fastmatch", "bit", "ffbase", "e1071", "lava", "prodlim","ada", "ipred", "evd", 'RecordLinkage'))
```

edit r.pbs as neede: nodes/tasks (tasks=nodes*16)
rm auth1/*

prepare cprojects.as1 on da4
```
gunzip -c ../cprojects.as | grep -v '^$'| perl -I /da3_data/lookup/ -ane 'use cmt;chop();$a=$_;@x=git_signature_parse($a); $fn=$x[0];$ln=$x[0];$fn=~s/\s.*//;$ln=~s/\s*$//;$ln=~s/.*\s//;$u=$x[1];$u=~s/\@.*//;print "$u;$x[0];$fn;$ln;$x[1];$a\n"' | gzip > ../cprojects.as1
```

Prepare data for r to read tasks = records/400
```
rm auth1/*
gunzip -c cprojects.as1  | head -12800 | split -l 400 - auth1/a.
qsub r.pbs 
```


# Run a large comparison
```
n=4096
fr=0
to=1
p=$(($n/16))
mkdir auth$n
split -n r/$n cprojects.as auth$n/a.
mkdir ${n}_${fr}-$to
sed "s/__OUT__/${n}_${fr}-$to/;s/__FROM__/$fr/;s/__TO__/$to/;s/auth1/auth$n/;s/__READERS__/$p/" tst.r > tst.${n}_${fr}-$to.r
sed "s/tst.r/tst.${n}_${fr}-$to.r/;s/walltime=02:00/walltime=00:30/;s/nodes=2/nodes=$p/;s/THREADS=32/THREADS=$n/" r.pbs > r${n}_${fr}-$to.pbs
qsub r${n}_${fr}-$to.pbs

...
#output is in 
#4096_{0-1,2-20,21-320,321-620,621-920,921-1220,1221-1520,1521-1820,1821-2048}_out

#map back to names
for i in {0..4095}; do cat 4096_0-1/outL.$i | awk 'BEGIN {i=1}{print $0";'$i';"i++}'; done | awk -F\; 'BEGIN {i=0}{print $1";"$3";"$4";"i++}' | gzip > 4096.L
cat a2d2v | perl map.perl | gzip > a2d2v.4096.L

cat extr.pbs 
#!/bin/bash
# File name: my-job-name.pbs

#PBS -N EXTR.NNN
#PBS -A csc229
#PBS -l walltime=00:30:00
#PBS -l nodes=1
#PBS -l gres=atlas1%atlas2

cd $MEMBERWORK/csc229/id
i=NNN
seq $i $(($i+15)) | while read j; do  echo $j; done | perl map1.perl > 4096_out/$i.txt


#do prediction 
cat pred.pbs 
#!/bin/bash
# File name: my-job-name.pbs

#PBS -N PRED.NNN
#PBS -A csc229
#PBS -l walltime=02:30:00
#PBS -l nodes=1
#PBS -l gres=atlas1%atlas2

module load r/3.4.2
cd $MEMBERWORK/csc229/id
i=NNN
#zcat 4096_out/NNN > 4096_out/NNN.txt
Rscript pred.$i.r
cat 4096_out/$i.p | perl map2.perl > 4096_out/$i.p.csv



#how long it took
seq 0 16 4080 | while read i; do seq $i $(($i+15)) | while read j; do  echo $j; done | perl map1.perl | gzip > 4096_out/$i; done
ls 4096_{0-1,2-20,21-320,321-620,621-920,921-1220,1221-1520,1521-1820,1821-2048}.out  | while read i; do cat $i | grep -E '^(STAR|END)' | awk '{print $2-i; i=$2}'|  tail -1; done| awk '{print i+=$1}' | tail -1
51460


```
