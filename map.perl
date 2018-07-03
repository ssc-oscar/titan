use strict;
use warnings;

open A, "zcat matches.csv |";
my (%n2i, %n2d);
while(<A>){
  chop();
  my ($n, $fnf, $lnf, $unf, $ch, $o, $off) = split (/;/, $_, -1);
  $n2i{$n}="$ch;$o";
  $n2d{$n}="$fnf;$lnf$unf";
}

while(<STDIN>){
  chop();
  my ($n, $n1, $d) = split (/;/, $_, -1);
  if (defined $n2i{$n}){
    if (defined $n2i{$n1}){
      print "$n2i{$n};$n2i{$n1};$d\n";
    }
  }
}
