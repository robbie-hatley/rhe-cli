#!/usr/bin/perl
use v5.40;
use Scalar::Util 'looks_like_number';

   sub bc ($a, $k) {
      my $num = 1; $num *= ( $a - $_ + 1 ) for 1..$k;
      my $den = 1; $den *= (      $_     ) for 1..$k;
      $num/$den;
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
say "Error: Number of arguments is not 2."           and exit  unless 2 == scalar(@ARGV);
say "Error: Argument 1 is not numeric."              and exit  unless looks_like_number($ARGV[0]);
say "Error: Argument 1 is less than zero."           and exit  unless $ARGV[0] >= 0;
say "Error: Argument 2 is not numeric."              and exit  unless looks_like_number($ARGV[1]);
say "Error: Argument 2 not a non-negative integer."  and exit  unless $ARGV[1] =~ m/^0$|^[1-9]\d*$/;
say "Error: Argument 2 is greater than Argument 1."  and exit  unless $ARGV[1] <= $ARGV[0];
my $a = $ARGV[0];
my $k = $ARGV[1];
say bc($a,$k);
