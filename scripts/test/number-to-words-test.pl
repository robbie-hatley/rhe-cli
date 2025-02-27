#!/usr/bin/perl
########################################################################################################################
# /rhe/scripts/math/number-to-words.pl
# Writes a number in words.
# Eg, given "398", outputs "three hundred and ninety-eight"
# Input: A single command-line argument consisting of a non-negative integer.
# Ootput: The number in words.
# Author: Robbie Hatley
# Edit history:
#    Sat Feb 20, 2016 - Wrote it.
########################################################################################################################
use v5.32;
use strict;
use warnings;

use List::Util 'sum';

sub number_to_words ($);

# main body of script:
{
   if ( 1 != @ARGV )
   {
      die "Error: This program takes exactly one argument, which must be\n",
          "a non-negative integer not exceeding 10^66-1.\n",
          "$!\n";
   }
   my $number = shift;
   say number_to_words($number);
   exit 0;
}

sub number_to_words ($)
{
   return 'no input'                  if @_ < 1;
   return 'excess input'              if @_ > 1;

   my $number = shift; # input string

   return 'undefined input'           if not defined $number;
   return 'not a nonnegative integer' if $number !~ m/^\d+$/;
   return 'out of range'              if length($number) > 66;
   return 'zero'                      if 0 == $number;

   # Dissect the number into its digits little-endian-wise,
   # so that the digit index is equal to log10 of place value.
   # While this is backwards from the way people read numbers,
   # it makes the programming MUCH easier.
   my @digits = ();
   unshift @digits, $_ for split //, $number;

   # Right-zero-pad @digits as necessary so that it will have
   # exactly 66 elements (usually most of them zeros):
   my $index   = 0;
   for ( $index = scalar(@digits) ; $index < 66 ; ++$index )
   {
      push @digits, 0;
   }

   my @groups =
   ( '' , qw(
      thousand       million           billion             trillion
      quadrillion    quintillion       sextillion          septillion
      octillion      nonillion         decillion           undecillion
      duodecillion   tredecillion      quattuordecillion   quindecillion
      sexdecillion   septendecillion   octodecillion       novemdecillion
      vigintillion
   ) );

   my @ones = ( '', qw(  one       two       three
                         four      five      six
                         seven     eight     nine   ) );

   my @teens = ( '', qw( eleven    twelve    thirteen
                         fourteen  fifteen   sixteen
                         seventeen eighteen  nineteen ) );

   my @tens = ( '', qw(  ten       twenty    thirty
                         forty     fifty     sixty
                         seventy   eighty    ninety ) );

   my @hundreds = ( '', 'one hundred',   'two hundred', 'three hundred',
                       'four hundred',  'five hundred',   'six hundred',
                      'seven hundred', 'eight hundred',  'nine hundred' );

   # Make a string to hold output:
   my $string  = '';

   # Iterate through digit groups of @digits in reverse order
   # (right to left, most-significant to least-significant,
   # remembering that we're writing all number BACKWARDS on purpose,
   # so that the digits are ordered ones, tens, hundreds, thousands, etc)
   # and separate out each group in turn as a slice:
   for (reverse 0..21)
   {
      my @slice = @digits[3*$_+0, 3*$_+1, 3*$_+2];

      #If this slice is populated:
      if (sum(@slice))
      {
         # if hundreds:
         if ($slice[2] > 0)
         {
            $string .= $hundreds[$slice[2]];

            # if we also have tens or ones, append ' and ':
            if ($slice[1] > 0 || $slice[0] > 0)
            {
               $string .= ' and ';
            }
         }

         # if teens:
         if ($slice[1] == 1 && $slice[0] > 0) # eleven through nineteen
         {
            $string .= $teens[$slice[0]];
         }

         # else if NOT in the teens:
         else
         {
            # if tens:
            if ($slice[1] > 0)
            {
               $string .= $tens[$slice[1]];

               # if we also have ones, append '-':
               if ($slice[0] > 0)
               {
                  $string .= '-';
               }
            }

            # if ones:
            if ($slice[0] > 0)
            {
               $string .= $ones[$slice[0]];
            }
         }

         # Finally, if this is not the least-significant group,
         # append group name (thousand, million, billion, whatever),
         # and also append ', ' if any less-significant digits are
         # non-zero:
         if ($_ > 0)
         {
            $string .= ' ';
            $string .= $groups[$_];
            if (sum(@digits[0 .. 3*$_-1]) > 0)
            {
               $string .= ', ';
            } # end appending ', ' if necessary
         } # end if (not least-significant group)
      } # end if (slice is populated)
   } # end for (each group)

   # We're done, so return $string:
   return $string;
}
