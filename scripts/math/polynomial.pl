#!/usr/bin/env perl

# This is a 110-character-wide ASCII Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# polynomial.pl
# Calculates polynomial functions.
#
# Edit history:
#    Sun Jan 31, 2021:
#       Wrote it.
#    Sun Feb 09, 2025:
#       Dramatically simplified: ASCII instead of Unicode; reduced width from 120 to 110; reduced version
#       requirement from "v5.32" to "v5.16"; got rid of "strict", "warnings", "common::sense", "utf8", etc.
##############################################################################################################

use v5.16;
sub Poly {
   my @coefs = @_;
   return sub
   {
      my $x = shift;
      my $v = 0;
      $v = $x * $v + $_ for @coefs;
      return $v
   }
}
my $f = Poly(@ARGV);
my ($x, $y);
for ( $x = -5.0 ; $x < 5.001 ; $x += 0.1 ) {
   $y = &$f($x);
   printf("f(%7.4f) = %10.4f\n", $x, $y);
}
