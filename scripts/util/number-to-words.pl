#!/usr/bin/env perl

# This is a 110-character-wide ASCII Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# /rhe/scripts/math/number-to-words.pl
# Writes a number in words.
# Example: given "398", outputs "three hundred and ninety-eight"
# Input:  A single command-line argument consisting of a non-negative integer
#         in the range of 0 through 10^102-1.
# Output: The number in words.
# Written by Robbie Hatley.
# Edit history:
# Sat Feb 20, 2016: Wrote first draft.
# Tue Jul 25, 2017: The "numbers-to-words" sub is now in this file only (I
#                   removed it from RH::Math because it's used only here).
# Sun Oct 13, 2019: Expanded range from 10^66-1 to 10^102-1.
# Thu Jan 23, 2020: Fixed bug on line 65 where @digits was 66 elements long
#                   instead of 102 as it should have been.
# Tue Feb 09, 2021: Refactored. Now using bignum, and input can be any non-negative real number from 0
#                   through 1e102-1. The fractional part of a non-integer input is truncated and the
#                   integral part is converted to a Math::BigInt object. Non-numeric, negative, and
#                   too-large inputs are rejected. Argument lists of length other than 1 are rejected.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Mon Jul 11, 2022: Added help; renamed "argv" to "process_arguments"; subsumed "error" into
#                   "process_arguments". Made $number a page-lexical varible. Fixed "number_to_words" so that
#                   it prints its own own result. Removed unnecessary error checking of string representation
#                   of $number in "number_to_words". Drastically simplified main body of script so that it
#                   only has 3 short, simple lines.
# Mon Mar 03, 2025: Got rid of "common::sense".
# Sun Apr 27, 2025: Reduced width from 120 to 110. Increased min ver from "v5.32" to "v5.36" to get
#                   automatic strict and warnings. Converted from UTF-8 Unicode to ASCII. Simplified shebang.
#                   Shortened subroutine names. Got rid of all prototypes. Converted bracing to C-style.
# Fri Feb 27, 2026: Changed "sum" to "sum0".
##############################################################################################################

use v5.36;
use bignum;
use List::Util 'sum0';

sub argv ; # Process arguments.
sub n2w  ; # Convert number to words.
sub help ; # Print help.

my $db = 0; # set to 1 for debug, 0 for normal
my $number;

{ # begin main body of script
   argv;
   n2w;
   exit;
} # end main body of script

# Subroutine definitions follow:

sub argv {
   # First, process and splice-out all non-argument options from @ARGV :
   for ( my $i = 0 ; $i < @ARGV ; ++$i ) {
      $_ = $ARGV[$i];
      if (/^-[\pL]{1,}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/) {
         if ( $_ eq '-h' || $_ eq '--help' ) {help; exit 777;}
         splice @ARGV, $i, 1;
         --$i;
      }
   }

   # Next, make sure we have exactly 1 argument left in @ARGV :
   if (scalar(@ARGV) != 1) {warn("Error: Wrong number of arguments.\n\n");help;exit 666;}

   # Store a BigInt version of our one argument in global variable $number :
   $number = Math::BigInt->new(int(Math::BigFloat->new($ARGV[0])));

   # Finally, abort if $number is not a number in the interval [0, 10^102-1]:
   if ($number->is_nan       ) {warn("Error: Argument is not a number.\n\n"); help; exit 666;}
   if ($number->blt(0)       ) {warn("Error: Argument is negative.    \n\n"); help; exit 666;}
   if ($number->bgt(1e102-1) ) {warn("Error: Argument is too large.   \n\n"); help; exit 666;}

   # If we get to here, we successfully processed all arguments, so return 1:
   return 1;
} # end sub argv

sub n2w {
   # Get string representation of $number :
   my $string = $number->bstr();

   # If debugging, print info on $string:
   if ($db) {
      say "string = $string";
      say "Length of string = ", length($string);
   }

   # Dissect this number's string into its digits little-endian-wise,
   # so that the digit index is equal to log10 of place value.
   # While this is backwards from the way people read numbers,
   # it makes the programming MUCH easier.
   my @digits = ();
   unshift @digits, $_ for split //, $string;

   # Right-zero-pad @digits as necessary so that it will have
   # exactly 102 elements (usually most of them zeros):
   my $index   = 0;
   for ( $index = scalar(@digits) ; $index < 102 ; ++$index ) {
      push @digits, 0;
   }

   # If debugging, print info on @digits:
   if ($db) {
      local $, = '';
      say "digits = @digits";
      print "Number of digits = "; say scalar(@digits);
   }

   my @groups =
   ( '' , qw(
      thousand              million               billion
      trillion              quadrillion           quintillion
      sextillion            septillion            octillion
      nonillion             decillion             undecillion
      duodecillion          tredecillion          quattuordecillion
      quindecillion         sexdecillion          septendecillion
      octodecillion         novemdecillion        vigintillion
      unvigintillion        duovigintillion       tresvigintillion
      quattuorvigintillion  quinquavigintillion   sesvigintillion
      septemvigintillion    octovigintillion      novemvigintillion
      trigintillion         untrigintillion       duotrigintillion
   ) );

   my @ones     = ( '',         'one',           'two',         'three',
                               'four',          'five',           'six',
                              'seven',         'eight',          'nine' );

   my @teens    = ( '',      'eleven',        'twelve',      'thirteen',
                           'fourteen',       'fifteen',       'sixteen',
                          'seventeen',      'eighteen',      'nineteen' );

   my @tens     = ( '',         'ten',        'twenty',        'thirty',
                              'forty',         'fifty',         'sixty',
                            'seventy',        'eighty',        'ninety' );

   my @hundreds = ( '', 'one hundred',   'two hundred', 'three hundred',
                       'four hundred',  'five hundred',   'six hundred',
                      'seven hundred', 'eight hundred',  'nine hundred' );

   # Make a string to hold output:
   my $output  = '';

   # Iterate through digit groups of @digits in reverse order, right-to-left,
   # most-significant to least-significant, remembering that @digits is
   # written BACKWARDS, so that $digits[i] is the 10^i column,
   # and separate out each group in turn as a slice:
   for (reverse 0..33) {
      my @slice = @digits[3*$_+0, 3*$_+1, 3*$_+2];

      #If this slice is populated:
      if (sum0(@slice)) {
         # if hundreds:
         if ($slice[2] > 0) {
            $output .= $hundreds[$slice[2]];

            # if we also have tens or ones, append ' and ':
            if ($slice[1] > 0 || $slice[0] > 0)
            {
               $output .= ' and ';
            }
         }

         # if teens:
         if ($slice[1] == 1 && $slice[0] > 0) { # eleven through nineteen
            $output .= $teens[$slice[0]];
         }

         # else if NOT in the teens:
         else {
            # if tens:
            if ($slice[1] > 0) {
               $output .= $tens[$slice[1]];

               # if we also have ones, append '-':
               if ($slice[0] > 0) {
                  $output .= '-';
               }
            }

            # if ones:
            if ($slice[0] > 0) {
               $output .= $ones[$slice[0]];
            }
         }

         # Finally, if this is not the least-significant group,
         # append group name (thousand, million, billion, whatever),
         # and also append ', ' if any less-significant digits are
         # non-zero:
         if ($_ > 0) {
            $output .= ' ';
            $output .= $groups[$_];
            if (sum0(@digits[0 .. 3*$_-1]) > 0) {
               $output .= ', ';
            } # end appending ', ' if necessary
         } # end if (not least-significant group)
      } # end if (slice is populated)
   } # end for (each group)

   # Print $output, unless it's empty, in which case print "zero":
   if (length($output) > 0 ) {
      say $output;
   }
   else {
      say "zero";
   }

   # We're done, so return 1:
   return 1;
} # end sub n2w

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "number-to-words.pl". This program prints the words for the integer
   part of the number given as its argument, provided that that number is a real
   number in the closed interval [0, 10^102-1]. The words given for a non-integer
   number will be for the integer part only. If the number of arguments is not 1,
   or if the argument is not a number, or if the argument is out-of-range, this
   program will print an error message and exit.

   Command lines:
   number-to-words.pl -h | --help    (to print this help and exit)
   number-to-words.pl ######         (to print the words for number ######)

   For example:
   %number-to-words.pl 205837
   two hundred and five thousand, eight hundred and thirty-seven

   Happy number-to-words converting!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
