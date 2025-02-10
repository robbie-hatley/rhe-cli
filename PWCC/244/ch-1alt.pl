#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

--------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
Solution in Perl for The Weekly Challenge 244-1, Alternate Version.
Written by Robbie Hatley on Tue Nov 21, 2023.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 1: Count Smaller
Submitted by: Mohammad S Anwar
You are given an array of integers. Write a script to calculate
the number of integers smaller than the integer at each index.

Example 1:
Input: @int = (8, 1, 2, 2, 3)
Output: (4, 0, 1, 1, 3)
For index = 0, count of elements less 8 is 4.
For index = 1, count of elements less 1 is 0.
For index = 2, count of elements less 2 is 1.
For index = 3, count of elements less 2 is 1.
For index = 4, count of elements less 3 is 3.

Example 2:
Input: @int = (6, 5, 4, 8)
Output: (2, 1, 0, 3)

Example 3:
Input: @int = (2, 2, 2)
Output: (0, 0, 0)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
In this "alternate" version, I'll use the obvious (mundane, prosaic) way: for each element, riffle through the
array and count smaller elements. Let's see how the run-time compares to my "sorted array" version.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of integers, in proper Perl syntax, like so:
./ch-1alt.pl '([17,54,-72,13,83],[5,4,3,2,1,0],[3,3,3,3,3,3],[13,-7,5,1,5,22])'

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

# Given an array of one-or-more integers, return the array
# of numbers of elements of the original array which are
# smaller than each element of the original array:
sub count_smaller ($aref) {
   my @smaller = ();
   foreach my $x (@$aref) {
      my $count = 0;
      foreach my $y (@$aref) {
         $y < $x and ++$count;
      }
      push @smaller, $count;
   }
   return @smaller;
}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:

# Inputs:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   # Example 1 Input:
   [8, 1, 2, 2, 3],
   # Expected Output: (4, 0, 1, 1, 3)

   # Example 2 Input:
   [6, 5, 4, 8],
   # Expected Output: (2, 1, 0, 3)

   # Example 3 Input:
   [2, 2, 2],
   # Expected Output: (0, 0, 0)
);

# Main loop:
for my $aref (@arrays) {
   say '';
   say 'Original Array = (', join(', ', @$aref), ')';
   say 'Size Of  Array = ', scalar(@$aref);
   !is_array_of_ints($aref)
   and say 'Error: Not an array of ints. Moving on to next array.'
   and next;
   say 'Smaller Counts = (', join(', ', count_smaller($aref)), ')';
}
exit;

# ------------------------------------------------------------------------------------------------------------
# DETERMINE AND PRINT EXECUTION TIME:
END {my $µs = 1000000 * (time - $t0);printf("\nExecution time was %.0fµs.\n", $µs)}
__END__
