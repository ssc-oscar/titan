use strict;
use warnings;

open A, "zcat a2d2v.4096.L|";
my %n2i;
while(<A>){
  chop();
  my ($ch, $o, $ch1, $o1, $d) = split (/;/, $_, -1);
  $n2i{"$ch;$o;$ch1;$o1"} = $d;
}

open A, "matches.csv";
my (%n2d);
while(<A>){
  chop();
  my ($n, $fnf, $lnf, $unf, $bfn, $bln, $bun, $ch, $o) = split (/;/, $_, -1);
  if ($bfn eq "TRUE"){
    $bfn = 1;
  }else{
    $bfn = 0;
  }
  if ($bln eq "TRUE"){
    $bln = 1;
  }else{
    $bln = 0;
  }
  if ($bun eq "TRUE"){
    $bun = 1;
  }else{
    $bun = 0;
  }


  $n2d{"$ch;$o"}="$fnf;$lnf;$unf;$bfn;$bln;$bun";
}



while(<STDIN>){
  chop();
  my $ch = $_;
  #for my $f ("4096_0-1", "4096_2-1023","4096_1024-2048"){ 
  for my $f ("4096_0-1", "4096_2-20","4096_21-320", "4096_321-620", "4096_621-920", "4096_921-1220", "4096_1221-1520", "4096_1521-1820", "4096_1821-2048"){ 
  #for my $f ("4096_1821-2048"){ 
    open A, "$f/outV.$ch";
    <A>;
    while (<A>){
      #id1;id2;n;e;ln;fn;un;ifn;a;b
      #2;413;0.656277056277056;0.688304093567251;0.742857142857143;0;0.849206349206349;0;0;0
      chop();
      my ($o, $o1, $na, $e, $ln, $fn, $un, $ifn, $n, $n1) = split (/;/, $_, -1);
      if (!defined $n2d{"$n;$o"}){ print STDERR "no=$n;$o\n";next;}
      if (!defined $n2d{"$n1;$o1"}){ print STDERR "no1=$n1;$o1\n"; next;}

      my ($fnf0, $lnf0, $unf0, $bfn0, $bln0, $bun0) = split (/\;/, $n2d{"$n;$o"}, -1);
      my ($fnf1, $lnf1, $unf1, $bfn1, $bln1, $bun1) = split (/\;/, $n2d{"$n1;$o1"}, -1);
      my ($fnf, $lnf, $unf) = ($fnf0 + $fnf1, $lnf0 + $lnf1, $unf0 + $unf1);
      my $key = "$n;$o;$n1;$o1";
      my $d = 0;
      $d = $n2i{$key} if (defined $n2i{$key});
      if ($bfn0+$bfn1 > 0){
        $fn = 0;
        $fnf = -20;
      }
      if ($bln0 + $bln1 > 0){
        $ln = 0;
        $lnf = -20;
      }
      if ($bun0 + $bun1 > 0){
        $un = 0;
        $unf = -20;
      }
      print "$key;$na;$e;$ln;$fn;$un;$ifn;$fnf;$lnf;$unf;$d\n";
    }
  }
}
