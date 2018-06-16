use strict;
use warnings;

open A, "zcat a2d2v.4096.L|";
my %n2i;
while(<A>){
  chop();
  my ($ch, $o, $ch1, $o1, $d) = split (/;/, $_, -1);
  $n2i{"$ch;$o;$ch1;$o1"} = $d;
}

while(<STDIN>){
  chop();
  my $ch = $_;
  for my $f ("4096_0-1", "4096_2-1023","4096_1024-2048"){ 
    open A, "$f/outV.$ch";
    <A>;
    while (<A>){
      #id1;id2;n;e;ln;fn;un;ifn;a;b
      #2;413;0.656277056277056;0.688304093567251;0.742857142857143;0;0.849206349206349;0;0;0
      chop();
      my ($o, $o1, $na, $e, $ln, $fn, $un, $ifn, $n, $n1) = split (/;/, $_, -1);
      my $key = "$n;$o;$n1;$o1";
      my $d = 0;
      $d = $n2i{$key} if (defined $n2i{$key});
      print "$key;$na;$e;$ln;$fn;$un;$ifn;$d\n";
    }
  }
}
