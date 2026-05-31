#!/usr/bin/env perl
##############################################################################################################
# "divisors.pl"
# Prints all of the positive divisors of a given positive integer under 10 billion.
# Author: Robbie Hatley.
# Edit history:
#    Mon Apr 27, 2015: Wrote it.
#    Mon Feb 10, 2025: Simplified it.
#    Sun May 31, 2026: Specified in description that we're dealing with POSITIVE divisors of POSITVE integers.
#                      Corrected errors in error handling. Now testing for more failure modes.
##############################################################################################################
use v5.16;
my  $i      = 0;
my  $Number = 0;
my  @divs   = ();
my  $divs   = 0;
die "Error: Must have exactly one argument.\n" if 1 != scalar @ARGV;
die "Error: Argument must be a positive integer.\n" if $ARGV[0] !~ m/^[1-9]\d*$/;
die "Error: Argument must be less than 10 billion.\n" if length($ARGV[0]>10);
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
