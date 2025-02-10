#!/usr/bin/env perl
##############################################################################################################
# "divisors.pl"
# Prints all of the divisors of the given positive integer.
# Author: Robbie Hatley.
# Edit history:
#    Mon Apr 27, 2015: Wrote it.
#    Mon Feb 10, 2025: Simplified it.
##############################################################################################################
use v5.16;
my  $i      = 0;
my  $Number = 0;
my  @divs   = ();
my  $divs   = 0;
if (1 != scalar @ARGV) {return 666;}
$Number = 0 + $ARGV[0];
for ( $i = 1 ; $i <= $Number ; ++$i ) {
   if (0 == $Number % $i) {
      push @divs, $i;
      ++$divs;
   }
}
say "$Number has $divs divisors:";
$, = ' ';
say @divs;
