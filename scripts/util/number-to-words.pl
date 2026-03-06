#!/usr/bin/env perl

# This is a 110-character-wide ASCII Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# /rhe/scripts/math/number-to-words.pl
# Writes numbers (given via stdin) in words.
# Example: given "398", outputs "three hundred and ninety-eight"
# Input:  Numbers given via stdin, one number per line.
# Output: The numbers in words.
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
# Fri Feb 27, 2026: Changed "sum" to "sum0". Added provision for negative numbers. Increased range to
#                   "the closed interval [-(10^102-1), +(10^102-1)]". Added warning to enclose integers with
#                   more than 9 sig figs in "double quotes" to prevent shell rounding. "n2w" now returns a
#                   return value instead of printing. "n2w" now does not alter its argument (it makes a copy).
# Sat Feb 28, 2026: Got rid of "padding to length 102"; now only left-padding with 0 as necessary to bring
#                   number of digits up to a factor of 3.
# Sun Mar 01, 2026: Got rid of "bignum" (now using "Math::BigFloat" and "Math::BigInt" instead). Got rid of
#                   "List::Util" and "sum0" (now using logic instead). Increased range to +- (10**154-1).
# Sun Mar 01, 2026: Increased limit to +- (10**3004-1).
# Mon Mar 02, 2026: Decreased limit to +- (10**3003-1). ("3004" was a bug.)
#                   Converted to Conway-Wechsler-Miakinen ("CWM").
#                   This is the same as Conway-Wechsler except "quin" instead of "quinqua".
# Thu Mar 05, 2026: Increased range to -∞ through +∞. Changed input from @ARGV to stdin.
##############################################################################################################

use v5.36;
use Math::BigFloat;
use Math::BigInt;

$"=', ';
my $db = 0; # set to 1 for debug, 0 for normal

# Start with the dictionary group names ("" through "decillion"):
my @groups =
( '' , qw( thousand million     billion     trillion   quadrillion  quintillion
                    sextillion  septillion  octillion  nonillion    decillion));

# Now store the Conway-Wechsler-Miakinen group name parts:
my @g_ones = ( '', qw( un    duo     tre      quattuor     quin         se        septe       octo       nove      ) );
my @g_tens = ( '', qw( deci  viginti triginta quadraginta  quinquaginta sexaginta septuaginta octoginta  nonaginta ) );
my @g_huns = ( '', qw( centi ducenti trecenti quadringenti quingenti    sescenti  septingenti octingenti nongenti  ) );

my @ones     = ( '',           'one',           'two',         'three',
                              'four',          'five',           'six',
                             'seven',         'eight',          'nine', );

my @teens    = ( '',        'eleven',        'twelve',      'thirteen',
                          'fourteen',       'fifteen',       'sixteen',
                         'seventeen',      'eighteen',      'nineteen', );

my @tens     = ( '',           'ten',        'twenty',        'thirty',
                             'forty',         'fifty',         'sixty',
                           'seventy',        'eighty',        'ninety', );

my @hundreds = ( '',   'one hundred',   'two hundred', 'three hundred',
                      'four hundred',  'five hundred',   'six hundred',
                     'seven hundred', 'eight hundred',  'nine hundred', );

# Subroutine predeclarations:
sub argv            ; # Process command-line arguments.
sub gname           ; # Given group index, return group name.
sub number_to_words ; # Convert number to words.
sub help            ; # Print help.

# Subroutine definitions follow:

# Process command-line arguments:
sub argv {
   for ( my $i = 0 ; $i < @ARGV ; ++$i ) {
      $_ = $ARGV[$i];
      if (/^-[\pL]{1,}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/) {
         if ( $_ eq '-h' || $_ eq '--help' ) {help; exit 777;}
         if ( $_ eq '-e' || $_ eq '--debug') {$db=1}
         splice @ARGV, $i, 1;
         --$i;
      }
   }
   return 1;
} # end sub argv

# Return the group name (dictionary or CWM) for a given group index:
sub gname ( $g ) {
   # Make a variable to hold the group name for group index $g:
   my $group = '';

   # If $g is no-greater-than 11, then just return the associated member of @groups:
   if ($g <= 11) {
      $group = $groups[$g];
   }

   # Otherwise, make the full Conway-Wechsler-Miakinen group name:
   else {
      # Make an array too hold triad names:
      my @tnames;

      # Get the traditional group number, which will always be one-less-than the group index $g
      # (eg: "million" = 1, "billion" = 2, "trillion" = 3, etc):
      my $n = $g - 1;

      # Decompose $n into and array of digits, and left-zero-pad the array to enforce 0==length%3:
      my @gdigits = split //, $n;
      my $padlen = (3 - scalar(@gdigits)%3)%3;
      for (0..$padlen-1) {unshift @gdigits, 0}
      if ($db) {say "\@gdigits = (@gdigits)"}

      # Make array of digit triads:
      my @triads;
      for my $tidx (0..scalar(@gdigits)/3-1) {
         if ($db) {say "\$tidx = $tidx"}
         push @triads, 0 + join '', @gdigits[3*$tidx+0,3*$tidx+1,3*$tidx+2];
      }
      if ($db) {say "number of triads = ", scalar @triads}
      if ($db) {say "triads = (@triads)"}

      # For each triad of digits, push the triad name onto @tnames:
      for my $tidx (0..$#triads) {
         # Get value of current triad:
         my $triad = $triads[$tidx];

         # Make a variable to hold the triad name:
         my $tname = '';

         # If value of triad is 0, set triad name to "nilli":
         if ( 0 == $triad ) {
            $tname = 'nilli';
         }

         # Else if value of triad is <= 10, use dictionary name, but chop-off the "on":
         elsif ( $triad <= 10 ) {
            $tname = $groups[$triad+1];
            $tname =~ s/on$//;
         }

         # Else construct the CWM name for this triad manually:
         else {
            # Get the raw CWM group name parts for ones, tens, and hundreds:
            my $g_one = $g_ones[int($triad/  1)%10];
            my $g_ten = $g_tens[int($triad/ 10)%10];
            my $g_hun = $g_huns[int($triad/100)%10];

            # Adjust "tre", "se", "septe", or "nove" if necessary:
            if ('tre' eq $g_one) {
               if
                  (     'viginti'      eq $g_ten
                     || 'triginta'     eq $g_ten
                     || 'quadraginta'  eq $g_ten
                     || 'quinquaginta' eq $g_ten
                     || 'octoginta'    eq $g_ten
                     || '' eq $g_ten && 'centi'        eq $g_hun
                     || '' eq $g_ten && 'trecenti'     eq $g_hun
                     || '' eq $g_ten && 'quadringenti' eq $g_hun
                     || '' eq $g_ten && 'quingenti'    eq $g_hun
                     || '' eq $g_ten && 'octingenti'   eq $g_hun
                  )
               {
                  $g_one .= 's';
               }
            } # end if (tre)

            if ('se' eq $g_one) {
               if
                  (
                        'viginti'      eq $g_ten
                     || 'triginta'     eq $g_ten
                     || 'quadraginta'  eq $g_ten
                     || 'quinquaginta' eq $g_ten
                     || '' eq $g_ten && 'trecenti'     eq $g_hun
                     || '' eq $g_ten && 'quadringenti' eq $g_hun
                     || '' eq $g_ten && 'quingenti'    eq $g_hun
                  )
               {
                  $g_one .= 's';
               }
               if
                  (
                        'octoginta'    eq $g_ten
                     || '' eq $g_ten && 'centi'        eq $g_hun
                     || '' eq $g_ten && 'octingenti'   eq $g_hun
                  )
               {
                  $g_one .= 'x';
               }
            } # end if (se)

            if ('septe' eq $g_one || 'nove' eq $g_one) {
               if
                  (
                        'viginti'      eq $g_ten
                     || 'octoginta'    eq $g_ten
                     || '' eq $g_ten && 'octingenti'   eq $g_hun
                  )
               {
                  $g_one .= 'm';
               }
               if
                  (
                        'deci'         eq $g_ten
                     || 'triginta'     eq $g_ten
                     || 'quadraginta'  eq $g_ten
                     || 'quinquaginta' eq $g_ten
                     || 'sexaginta'    eq $g_ten
                     || 'septuaginta'  eq $g_ten
                     || '' eq $g_ten && 'centi'        eq $g_hun
                     || '' eq $g_ten && 'ducenti'      eq $g_hun
                     || '' eq $g_ten && 'trecenti'     eq $g_hun
                     || '' eq $g_ten && 'quadringenti' eq $g_hun
                     || '' eq $g_ten && 'quingenti'    eq $g_hun
                     || '' eq $g_ten && 'sescenti'     eq $g_hun
                     || '' eq $g_ten && 'septingenti'  eq $g_hun
                  )
               {
                  $g_one .= 'n';
               }
            } # end if (septe or nove)

            # Make the triad name by tacking-together ones+tens+hundreds in that order. Yes, in THAT order.
            $tname=$g_one.$g_ten.$g_hun;

            # Elide any final vowel:
            $tname =~ s/[aeiou]$//;

            # tack 'illi' onto right end of triad name:
            $tname .= 'illi';
         } # end else (construct CWM name for triad manually)

         # Push triad name onto @tnames:
         push @tnames, $tname;
      } # end for (each triad)

      # Join triads to form group;
      $group = join '', @tnames;

      # Tack a final "on" onto the end (to change the last "illi" to "illion"):
      $group .= 'on';
   } # end else (make full CWM name)

   # Finally, return our group name:
   return $group;
}

# Return the Conway-Wechsler-Miakinen (CWM) English short-form name of a given integer.
# This will be the same as dictionary names for integers under 10**36.
# This is also the same as Conway-Wechsler except that CWM uses "quin" instead of "quinqua".
sub number_to_words ( $n ) {
   # Get a new, local copy of $n:
   my $local = $n->copy();

   # Create a "$sign" string, defaulting to empty:
   my $sign = '';

   # If $local is negative, negate it and set $sign to 'negative ':
   if ( $local->is_negative() ) {
      $local->bneg();
      $sign = 'negative ';
   }

   # Get a string representation of $local :
   my $string = $local->bstr();

   # Left-zero-pad $string to give it a length which is a multiple of 3:
   my $oldlen = length($string);
   my $padlen = (3-$oldlen%3)%3;
   $string = '0'x$padlen . $string;
   my $newlen = length($string);

   # If debugging, print info on $string:
   if ($db) {
      say "String = $string";
      say "String length before padding = $oldlen";
      say "String length after  padding = $newlen";
      say "Length of \@groups = ", scalar(@groups);
   }

   # Dissect this number's string into its digits:
   my @digits = split //, $string;

   # If debugging, print info on @digits:
   if ($db) {
      local $, = '';
      say "digits = @digits";
      say "Number of digits = ", scalar(@digits);
   }

   # Make an array to hold the full names of all 3-digit place-value groups
   # (eg: ("twenty-seven billion", "twelve million", "one hundred and two thousand", "seventeen") ):
   my @places = ();

   # Iterate through digit groups of @digits from left (most-significant) to right (least-significant) and
   # separate out each group in turn as a slice:
   for my $i (0..$newlen/3-1) {                       # $i = digit group index
      my $g = ($newlen/3-1)-$i;                       # $g = names group index
      if ($db) {say "\$i = $i  \$g = $g";}
      my @slice = @digits[3*$i+0, 3*$i+1, 3*$i+2];    # @slice = digits of current group
      my $prefix = ''; # prefix     for this digit group (eg, "forty-seven")
      my $group  = ''; # group name for this digit group (eg, "nonillion")
      my $place  = ''; # full  name for this digit group (eg, "forty-seven nonillion")

      #If this slice is populated, push its full name onto @places:
      if ( $slice[0] || $slice[1] || $slice[2] ) {
         # if hundreds:
         if ($slice[0] > 0) {
            $prefix .= $hundreds[$slice[0]];

            # if we also have tens or ones, append ' and ':
            if ($slice[1] > 0 || $slice[2] > 0)
            {
               $prefix .= ' and ';
            }
         }

         # if teens:
         if ($slice[1] == 1 && $slice[2] > 0) { # eleven through nineteen
            $prefix .= $teens[$slice[2]];
         }

         # else if NOT in the teens:
         else {
            # if tens:
            if ($slice[1] > 0) {
               $prefix .= $tens[$slice[1]];

               # if we also have ones, append '-':
               if ($slice[2] > 0) {
                  $prefix .= '-';
               }
            }

            # if ones:
            if ($slice[2] > 0) {
               $prefix .= $ones[$slice[2]];
            }
         }

         # Get group name ('', 'thousand', 'million', 'billion', or whatever):
         $group = gname($g);

         # Get full name:
         $place = "$prefix $group";

         # Push full name of this digit group onto @places:
         push @places, $place;
      } # end if (slice is populated)
   } # end for (each digit group)

   # Join @places into an output string:
   my $output = join ', ', @places;

   # If $output is an empty string, our number is 0, so set $output to 'zero':
   if ( 0 == length($output) ) {
      $output = 'zero';
   }

   # Append sign string to left end of $output :
   $output = $sign.$output;

   # Return $output :
   return $output;
} # end sub n2w

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "number-to-words.pl". This program prints the words for the integer
   part of each real number given via stdin, one number per line. The words given
   for a non-integer number will be for the integer part only.

   Options:
   -h or --help  : Print this help and exit.
   -e or --debug : Debug.

   Arguments:
   This program ignores all non-option arguments.

   Command lines:
   number-to-words.pl -h | --help           (to print this help and exit)
   number-to-words.pl [options] < file.txt  (to print words for numbers)

   For example:
   %echo "-38547275925477542957" | number-to-words.pl
   negative thirty-eight quintillion, five hundred and forty-seven quadrillion,
   two hundred and seventy-five trillion, nine hundred and twenty-five billion,
   four hundred and seventy-seven million, five hundred and forty-two thousand,
   nine hundred and fifty-seven

   Happy number-to-words converting!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help

# Main body of script:
argv;
for (<>) {
   chomp;
   my $number = Math::BigInt->new(int(Math::BigFloat->new($_)));
   # Warn-and-skip if $number is not a number:
   if ( $number->is_nan ) {
      warn("Error: Input \"$_\" is not a number.\n\n");
      next;
   }
   say number_to_words($number);
}
