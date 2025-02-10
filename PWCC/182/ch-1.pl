#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

--------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
Solutions in Perl for The Weekly Challenge 182-1.
Written by Robbie Hatley on Thu Oct 12, 2023.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 1: Max Index
Submitted by: Mohammad S Anwar
Given a list of integers, write a script to find the index of
the first biggest number in the list.

Example 1:
Input: @n = (5, 2, 9, 1, 7, 6)
Output: 2 (as 3rd element in the list is the biggest number)

Example 2:
Input: @n = (4, 2, 3, 1, 5, 0)
Output: 4 (as 5th element in the list is the biggest number)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
This is just a matter of keeping track of "index of biggest seen so far", and only updating that if-and-when
a bigger (not same-size) number is found.

Mathematically, this should work for any ordered number set (such as integers, rationals, irrationals, reals,
but not complex or quaterions or octonions which aren't ordered).

However, in computation, only integers will work right, because the place-value (eg, binary or decimal)
representations of many reals are infinite, whereas computers can only use a finite number of binary digits
to represent any one number.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of ingeters, in proper Perl syntax, like so:
./ch-1.pl "([1,3,-7,3,2,1], [7,6,5,7,6,5])"

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
our $t0; BEGIN {$t0 = time}

# ------------------------------------------------------------------------------------------------------------
# SUBROUTINES:

sub index_of_greatest ($aref) {
   my $vog = $$aref[0]; # $vog = Value Of Greatest
   my $iog = 0;         # $iog = Index Of Greatest
   for ( my $idx = 1 ; $idx <= $#$aref ; ++$idx ) {
      if ( $$aref[$idx] > $vog ) {
         $vog = $$aref[$idx];
         $iog = $idx;
      }
   }
   return $iog;
}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:

# Inputs:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   # Example 1 input:
   [5, 2, 9, 1, 7, 6],

   # Example 2 input:
   [4, 2, 3, 1, 5, 0],
);

# Main loop:
for my $aref (@arrays) {
   my $iog = index_of_greatest($aref);
   say '';
   say 'Array = (', join(', ', @$aref), ')';
   say "Index of greatest element = $iog";
}
exit;

# ------------------------------------------------------------------------------------------------------------
# DETERMINE AND PRINT EXECUTION TIME:
END {
   my $µs = 1000000 * (time - $t0);
   printf("\nExecution time was %.0fµs.\n", $µs);
}
__END__
