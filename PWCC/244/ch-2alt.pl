#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

--------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
Solution in Perl for The Weekly Challenge 244-2, Alternate Version.
Written by Robbie Hatley on Tue Nov 21, 2023.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 2: Group Hero
Submitted by: Mohammad S Anwar

You are given an array of integers representing the strength.
Write a script to return the sum of the powers of all possible
combinations; power is defined as the square of the largest
number in a sequence, multiplied by the smallest.

Example 1:
Input: @nums = (2, 1, 4)
Output: 141
Group 1: (2) => square(max(2)) * min(2) => 4 * 2 => 8
Group 2: (1) => square(max(1)) * min(1) => 1 * 1 => 1
Group 3: (4) => square(max(4)) * min(4) => 16 * 4 => 64
Group 4: (2,1) => square(max(2,1)) * min(2,1) => 4 * 1 => 4
Group 5: (2,4) => square(max(2,4)) * min(2,4) => 16 * 2 => 32
Group 6: (1,4) => square(max(1,4)) * min(1,4) => 16 * 1 => 16
Group 7: (2,1,4) => square(max(2,1,4)) * min(2,1,4) => 16 * 1 => 16
Sum: 8 + 1 + 64 + 4 + 32 + 16 + 16 => 141

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
In this "alternate" version I'll use CPAN module "Math::Combinatorics". Let's seen how the run time compares.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of integers, in proper Perl syntax, like so:
./ch-2alt.pl '([4,8,16,32],[-3,45,-17,63,-54],[0,0,0,0,0])'

Output is to STDOUT and will be each input array followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS AND MODULES USED:

use v5.38;
use strict;
use warnings;
use utf8;
use warnings FATAL => 'utf8';
use Time::HiRes 'time';
use Math::Combinatorics;
use List::Util ('min', 'max');

# ------------------------------------------------------------------------------------------------------------
# START TIMER:
our $t0;
BEGIN {$t0 = time}

# ------------------------------------------------------------------------------------------------------------
# SUBROUTINES:

# Is a given array an array of integers?
sub is_array_of_ints($aref) {
   return 0 if 'ARRAY' ne ref $aref;
   for (@$aref) {
      return 0 if !/^-[1-9]\d*$|^0$|^[1-9]\d*$/;
   }
   return 1;
}

# What is the sum of the powers of all combinations?
sub sum_pow_cmbs ($aref) {
   my $total = 0;
   my $asize = scalar(@$aref);
   my @combs = ();
   foreach my $csize ( 1 .. $asize ) {
      push @combs, combine($csize,@$aref);
   }
   foreach my $cref ( @combs ) {
      $total += min(@$cref)*max(@$cref)*max(@$cref);
   }
   return $total;
}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:

# Inputs:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   # Example 1 Input:
   [2, 1, 4],
   # Expected Output: 141
);

# Main loop:
for my $aref (@arrays) {
   say '';
   say 'Array = (', join(',',@$aref), ')';
   is_array_of_ints($aref)
   or say 'Error: Not an array of ints. Moving on to next array.'
   and next;
   say 'Sum of powers of combinations = ', sum_pow_cmbs($aref);
}
exit;

# ------------------------------------------------------------------------------------------------------------
# DETERMINE AND PRINT EXECUTION TIME:
END {my $µs = 1000000 * (time - $t0);printf("\nExecution time was %.0fµs.\n", $µs)}
__END__
