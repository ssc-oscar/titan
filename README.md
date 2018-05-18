# Pairwise similarity at scale using pbdR

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
install.packages('RecordLinkage')
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

