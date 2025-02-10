#!/usr/bin/env perl

use v5.36;
use bigint;

# Factorial of x:
sub fact ($x) {
   my $f = 1;
   for ( my $i = 2 ; $i <= $x ; ++$i ) {
      $f *= $i;
   }
   return $f;
}

{ # begin main
   if ( 1 != scalar(@ARGV) || 0+$ARGV[0] < 0 ) {
      warn("Error: Must have one argument, which must be a non-negative integer.\n");
      exit 666;
   }
   my $n   = 0 + $ARGV[0];
   my $num = fact(2*$n);
   my $den = fact($n+1)*fact($n);
   my $c   = $num/$den;
   say "Catalan[$n] = $c  ";

} # end main
