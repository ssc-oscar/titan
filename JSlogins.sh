#!/bin/bash

# prepare logins from the projects where users reporting bugs on popular JS projects have made commits to

cat logins_list | gzip > js_authors.gz

#commits from big query filterd on js users reporting bugs
zcat c2a_s_p*.gz|~/bin/grepField.perl js_authors.gz 2 | ~/lookup/splitSec.perl c2a_js_authors. 32
for j in {0..31}; do zcat c2a_js_authors.$j.gz | lsort 5G -t\; -k1 | gzip > c2a_js_authors.$j.s; done

#get author id from the actual commit
for j in {0..31}; do zcat c2a_js_authors.$j.s| join -t\; - <(zcat c2taFO.$j.s) | gzip > c2ghtaFO$j.s; done 


for j in {0..31}
do zcat c2a_js_authors.$j.s | cut -d\; -f1 | uniq | gzip > cJSO$j.s &
done
wait
echo cJSO$j.s

#get projects for all the relevant commits
for j in {0..31}
do zcat c2pFullO$j.s | join -t\; - <(zcat cJSO$j.s) | gzip > c2pJSO$j.s &
done
wait
echo c2pJSO$j.s
for j in {0..31}
do zcat c2pJSO$j.s | cut -d\; -f2 | uniq | $HOME/bin/lsort 10M -u | gzip > pJSO$j.s &
done 
wait
echo pJSO$j.s
for j in {0..31}
do zcat pJSO$j.s
done | $HOME/bin/lsort 2G -u | perl -I $HOME/lookup -I $HOME/lib64/perl5 $HOME/lookup/splitSecCh.perl pJSO. 32 
echo pJSO.

# get authors for these projects
for j in {0..31}
do zcat p2aFullO$j.s | join -t\; - <(zcat pJSO.$j.gz) | gzip > p2aJSO$j.s &
done
wait
echo p2aJSO$j.s
for j in {0..31}
do zcat p2aJSO$j.s | cut -d\; -f2 | $HOME/bin/lsort 50M -t\; -u | gzip > afJSO$j.s &
done
wait
echo afJSO$j.s

for j in {0..31}
do zcat afJSO$j.s
done | $HOME/bin/lsort 2G -t\; -u | gzip > afJSO

#5+M authors, do disambiguation on them
zcat afJSO |  grep -v '^$'| perl -I $HOME/lookup/ -I $HOME/lib64/perl5 -ane 'use cmt;use Compress::LZF;chop();$a=$_;@x=git_signature_parse($a); $fn=$x[0];$ln=$x[0];$fn=~s/\s.*//;$ln=~s/\s*$//;$ln=~s/.*\s//;$u=$x[1];$u=~s/\@.*//;print "$u;$x[0];$fn;$ln;$x[1];$a\n"' | gzip > asfeaturesJSO


```
n=59808
fr=0
to=1
p=$(($n/16))
mkdir auth$n
zcat asfeaturesJSO | grep -v '^;;;' > asfeaturesJSO2M
split -n r/$n asfeaturesJSO2M auth$n/a.
mkdir ${n}_${fr}-$to
sed "s/__OUT__/${n}_${fr}-$to/;s/__FROM__/$fr/;s/__TO__/$to/;s/auth1/auth$n/;s/__READERS__/$p/" tst.r > tst.${n}_${fr}-$to.r
sed "s/tst.r/tst.${n}_${fr}-$to.r/;s/walltime=02:00/walltime=00:30/;s/NNODES/$p/;s/NTHREADS/$n/" r.pbs > r${n}_${fr}-$to.pbs
qsub r${n}_${fr}-$to.pbs

```