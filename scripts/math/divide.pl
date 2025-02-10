#!/usr/bin/env perl

# This is a 110-character-wide ASCII Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# /rhe/scripts/math/divide.pl
# Divides one positive integer by another and prints the quotient, offset to
# repetition, and period of repetition.
# Author: Robbie Hatley
# Edit history:
#    Thu Jan 11, 2018:
#       Wrote first draft.
#    Sat Jan 13, 2018:
#       Finally got it working correctly.
#    Mon Feb 10, 2025:
#       Simplified: Changed invocation from "#!/usr/bin/perl" to "#!/usr/bin/env perl"; changed encoding from
#       Unicode/UTF-8 to ASCII; reduced width from 120 to 110; got rid of "strict", "warnings", "utf8", etc;
#       changed "bigint" to "bignum" (since we'll be doing division); added "try => 'GMP'"; changed required
#       version from "v5.32" to "v5.36" to get signatures; removed prototypes and added signatures; removed
#       subroutine predeclaration and moved subroutine up; and changed brace formatting to C-style.
##############################################################################################################

use v5.36;
use bignum try => 'GMP';

# Divide one positive integer by another, returning floating-point quotient
# up to repetition point (if any), periodicity of repeating decimal (0 if none),
# and repeated string of digits ('' if none):
sub divide($dividend, $divisor) {
   my $index       = 0;
   my $dotindex    = 0;
   my $remainder   = 0;
   my @Remainders  = ();
   my $into        = 0;
   my $product     = 0;

   my $quotient    = 0;
   my $offset      = 0;
   my $period      = 0;

   # If dividend >= divisor, this is an "improper fraction",
   # so make it "proper":
   if ($dividend >= $divisor ) { # eg, 36/7
      $quotient = (int($dividend/$divisor));
      $dividend -= ($quotient * $divisor);
   }

   # The integral part of the quotient, if any, has now been calculated.
   # Now, what about the fractional part, if any?

   # If there IS NO fractional part,
   # Leave the quotient as it is, an integer with no decimal point.
   # Leave the period   as it is, 0.
   # Leave the pattern  as it is, ''.

   # But if there IS a fractional part to this quotient, then:
   # 1. Find the quotient (up to repetition point, if any).
   # 2. Find the period  of repetition (if any).
   # 3. Find the pattern of repetition (if any).
   if ( 0 < $dividend && $dividend < $divisor ) {
      $quotient .= '.';                       # Tack on decimal point.
      $remainder = $dividend;                 # Load dividend into remainder.
      $index = 1;                             # Place value = 10^(-$index)
      DIGIT: while (1) {
         $remainder .= '0';                   # Bring down the first of the infinite zeros.
         $offset = 0;
         foreach (@Remainders) {              # Riffle through logged remainders.
            last DIGIT if ($remainder == $_); # End division process if remainder is a repeat.
            ++$offset;                        # Increment $offset
         }
         push @Remainders, $remainder;        # Otherwise, push remainder onto @Remainders.
         $into = int($remainder / $divisor);  # How many times does divisor go INTO remainder?
         $quotient .= $into;                  # INTO is 10^(-$index) digit of quotient.
         $product = $into * $divisor;         # Multiply INTO by divisor.
         $remainder -= $product;              # Subtract product from remainder.
         last DIGIT if $remainder == 0;       # If remainder is 0, this is a terminating decimal expansion.
         ++$index;                            # Increment place value one right-ward and iterate.
         if ($index > 1000000) {die "Error in \"divide.pl\": over a million iterations.\n";}
      }

      if ($remainder == 0) {                  # If remainder is now 0,
         $period  = 0;                        # this decimal fraction is non-periodic.
      }
      else {                                  # Otherwise, determine period and pattern.
         $period   = scalar(@Remainders) - $offset;
         $dotindex = index($quotient, '.');
      }
   } # End if (there's a fractional part).

   if ($period > 0) {
      $quotient = substr($quotient, 0, $dotindex + 1 + $offset)
          . '(' . substr($quotient,    $dotindex + 1 + $offset) . ')';
   }
   return ($quotient, $offset, $period); # Return results to caller.
}


# Main body of program:
{
   my $dividend = shift;
   my $divisor  = shift;
   my ($quotient, $offset, $period) = divide($dividend,$divisor);
   say "quotient = $quotient";
   say "offset   = $offset";
   say "period   = $period";
	exit 0;
}

=pod

   1m = (100cm/1m)(1in/2.54cm)
      = 100/2.54      inches
      = 10000/254     inches
      = 5000/127      inches
      = (39 + 47/127) inches
   47/127 is a proper fraction in lowest form and has an Abelian digit repetition group of order 42:
   47/127 = 0.(370078740157480314960629921259842519685039)

=cut
