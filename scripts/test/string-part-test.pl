#!/usr/bin/perl

use v5.32;

use RH::Math qw(C);

for ( my $n = 0 ; $n <= 15 ; ++$n ) {
   my $c = 0;
   for ( my $k = 0 ; $k <= $n-1 ; ++$k ) {
      # Add C(n-1,k) to $c:
      $c += C($n-1,$k);
   }
   printf("catalan[%2d] = %10d\n", $n, $c);
}
