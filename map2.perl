use strict;
use warnings;

open A, "zcat 4096.L|";
my %n2i;
while(<A>){
  chop();
  my ($n, $ch, $o, $off) = split (/;/, $_, -1);
  $n2i{"$ch;$o"}=$n;
}
open A, "zcat a2d2v.4096.L|";
my %n2i1;
while(<A>){
  chop();
  my ($ch, $o, $ch1, $o1, $d) = split (/;/, $_, -1);
  $n2i1{"$ch;$o;$ch1;$o1"} = $d;
}
#open A, "zcat 
while(<STDIN>){
  chop();
  my ($n, $o, $n1, $o1, @rest) = split (/;/, $_, -1);
  my $a="$n;$o";
  my $b ="$n1;$o1";
  my $k = "$a;$b";
  my $str = join ';', @rest;
  print "$k;$n2i{$a};$n2i{$b};$n2i1{$k};$str\n";
}
