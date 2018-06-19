use strict;
use warnings;

open A, "zcat 4096.L|";
my %n2i;
while(<A>){
  chop();
  my ($n, $ch, $o, $off) = split (/;/, $_, -1);
  $n2i{"$ch;$o"}=$n;
}

while(<STDIN>){
  chop();
  my ($n, $o, $n1, $d) = split (/;/, $_, -1);
  print "".$n2i{"$n;$o"}.";".$n2i{"$n1;$o1"}."\n";
}
