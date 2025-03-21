#!/usr/bin/env perl
# Filename: "binomial-coefficient.pl".
# Description: Calculates binomial coefficient bc(a,k) for any non-negative real number a
# and for any non-negative integer k.
# Written by Robbie Hatley.
# Edit history:
#   Tue Feb 04, 2025: Wrote it.
#   Sun Feb 09, 2025: Now using "bignum" for unlimited precision.
#   Mon Feb 10, 2025: Added this title block. Changed from "bignum" to "bigrat".
#   Fri Mar 21, 2025: Refactored for readibility and clarity.

# ======= PRAGMAS AND MODULES: ===============================================================================

use v5.36;
use strict;
use warnings;

use Scalar::Util qw( looks_like_number );
use bigrat       qw( lib GMP           );

# ======= VARIABLES: =========================================================================================

my @Opts  = ()    ;
my @Args  = ()    ;
my $Debug = 0     ;
my $Help  = 0     ;
my $X     = undef ;
my $Y     = undef ;

# ======= SUBROUTINE PREDECLARATIONS: ========================================================================

sub argv;
sub binomial_coefficient;
sub help;

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   argv;
   if ($Debug) {say "In main after argv.   \$X = $X   \$Y = $Y";}
   if ($Help ) {help; exit 777;}
   my $b = binomial_coefficient($X, $Y);
   1 == $b->denominator() and say $b->as_int() or say $b->as_float(100_000);
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV:
sub argv {
   # Get options and arguments:
   foreach (@ARGV) {
      if (/^-/) {push @Opts, $_}
      else      {push @Args, $_}
   }

   # Process options:
   foreach (@Opts) {
      /^-\p{L}*e/ || /^--debug$/ and $Debug = 1;
      /^-\p{L}*h/ || /^--help$/  and $Help  = 1;
   }

   # Process arguments:
   die "Error: Number of arguments is not 2.\n"           unless 2 == scalar(@Args);
   die "Error: Argument 1 is not numeric.\n"              unless looks_like_number($Args[0]);
   die "Error: Argument 1 is less than zero.\n"           unless $Args[0] >= 0;
   die "Error: Argument 2 is not numeric.\n"              unless looks_like_number($Args[1]);
   die "Error: Argument 2 not a non-negative integer.\n"  unless $Args[1] =~ m/^0$|^[1-9]\d*$/;
   die "Error: Argument 2 is greater than Argument 1.\n"  unless $Args[1] <= $Args[0];
   $X = $Args[0];
   $Y = $Args[1];

   # Return success code 1 to caller:
   return 1;
}

# Calculate binomial coefficient:
sub binomial_coefficient ($x, $y) {
   my $num = 1;
   my $den = 1;
   for (1..$y) {
      my $i = $_;
      $num *= ( $x - $i + 1 );
      $den *= (      $i     );
   }
   return $num/$den;
}

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to Robbie Hatley's nifty binomial coefficient program. Given
   arguments X and Y, this program prints the binomial coefficient bc(X,Y),
   but with X not limited to being an integer! Indeed, X can be any
   non-negative real number. Y, on the other hand, must be a non-negative
   integer such that Y <= X. While it is true that "bc(13.7,3)" is hard to
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
   return 1;
}
