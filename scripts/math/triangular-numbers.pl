#!/usr/bin/env perl

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# /rhe/scripts/math/triangular-numbers.pl
# Generates and prints all of the triangular numbers up to the least
# triangular number which is equal to or greater than a given positive
# integer
# Author: Robbie Hatley.
# Edit history:
#    Fri Feb 19, 2016 - Wrote it.
##############################################################################################################

use v5.32;

sub NextTriangularNumber;
sub NumberOfDivisors;

# Main:
{
   if (1 != scalar @ARGV)
   {
      say "This program must take exactly 1 argument, which must be "
        . "a positive integer.\n";
      exit (666);
   }
   my $Limit = 0 + $ARGV[0];
   my $Index = 0;
   my $Triangle = 0;
   do
   {
      ++$Index;
      $Triangle += $Index;
      printf("%20d%30d\n", $Index, $Triangle);
   } while $Triangle <= $Limit;
   exit 0;
}
