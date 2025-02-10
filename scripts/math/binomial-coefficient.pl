#!/usr/bin/env perl
# Filename: "binomial-coefficient.pl".
# Description: Calculates binomial coefficient bc(a,k) for any non-negative real number a
# and for any non-negative integer k.
# Written by Robbie Hatley.
# Edit history:
#    Tue Feb 04, 2025:
#       Wrote it.
#    Sun Feb 09, 2025:
#       Now using "bignum" for unlimited precision.
#    Mon Feb 10, 2025:
#       Added this title block. Changed from "bignum" to "bigrat".

use v5.40;
use Scalar::Util 'looks_like_number';
use bigrat lib => 'GMP';
sub bc ($a, $k) {
   my $num = 1;
   my $den = 1;
   for (1..$k) {
      my $i = $_;
      $num *= ( $a - $i + 1 );
      $den *= (      $i     );
   }
   return $num/$den;
}

foreach my $arg (@ARGV) {
   if ("-h" eq $arg || "--help" eq $arg) {
      print ((<<'      END_OF_HELP') =~ s/^      //gmr);
      Welcome to Robbie Hatley's nifty binomial coefficient program. Given
      arguments a and k, this program prints the binomial coefficient bc(a,k),
      but with a not limited to being an integer! Indeed, a can be any
      non-negative real number. k, on the other hand, must be a non-negative
      integer such that k <= a. While it is true that "bc(13.7,3)" is hard to
      visualize as "ways of picking 3 cards from a deck of 13.7 cards", such
      "generalized" binomial coefficients are useful for such things as series
      approximations for the perimeter of an ellipse (among other uses).

      One way to visualize bc(13.7,3) in terms of playing cards is to realize
      that the coefficient can be generated card by card by multiplying
      together "number of available cards to choose from" for each card to be
      chosen, then divide by the number of permutations of 3 things (6).
      For the first card we have 13.7 choices, for the second we have 12.7,
      and for the third we have 11.7, so the coefficient is given by
      13.7 * 12.7 * 11.7 / 6 = 339.2805 exactly. Indeed if a is rational,
      then bc(a,k) will also be rational.

      But don't try this in Vegas! The poker dealer will not be amused
      if you plop down 2.7 kings and say "Look, I have a 2.7-of-a-kind!";
      he/she will probably call security and have you escorted out.
      END_OF_HELP
      exit;
   }
}
die "Error: Number of arguments is not 2.\n"           unless 2 == scalar(@ARGV);
die "Error: Argument 1 is not numeric.\n"              unless looks_like_number($ARGV[0]);
die "Error: Argument 1 is less than zero.\n"           unless $ARGV[0] >= 0;
die "Error: Argument 2 is not numeric.\n"              unless looks_like_number($ARGV[1]);
die "Error: Argument 2 not a non-negative integer.\n"  unless $ARGV[1] =~ m/^0$|^[1-9]\d*$/;
die "Error: Argument 2 is greater than Argument 1.\n"  unless $ARGV[1] <= $ARGV[0];
my $a = $ARGV[0];
my $k = $ARGV[1];
my $b = bc($a,$k);
1 == $b->denominator()
and say "Result is integer. " and say $b->as_int()
or  say "Result is rational." and say $b->as_float(100_000);
