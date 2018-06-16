use strict;
use warnings;

open A, "zcat 4096.L|";
my %n2i;
while(<A>){
  chop();
  my ($n, $ch, $o, $off) = split (/;/, $_, -1);
  $n2i{$n}="$ch;$o";
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
