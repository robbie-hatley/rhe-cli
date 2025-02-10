#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

--------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
Solutions in Perl for The Weekly Challenge xxx-2.
Written by Robbie Hatley on Xxx Xxx xx, 2023.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 187-2: Magical Triplets
Submitted by: Mohammad S Anwar
You are given a list of positive numbers, @n, having at least 3
numbers. Write a script to find the triplets (a, b, c) from the
given list that satisfies the following rules:
1. a + b > c
2. b + c > a
3. a + c > b
4. a + b + c is maximum.
In case you end up with more than one triplets having the
maximum then pick the triplet where a >= b >= c.

Example 1:
    Input: @n = (1, 2, 3, 2);
    Output: (3, 2, 2)

Example 2:
    Input: @n = (1, 3, 2);
    Output: ()

Example 3:
    Input: @n = (1, 1, 2, 3);
    Output: ()

Example 4:
    Input: @n = (2, 4, 3);
    Output: (4, 3, 2)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
This is straightforward: make a sub which uses triple-nested loops to generate all triplets, then pushes those
which are "magic" onto an array "@magic", then pushes those which are max onto at array "max", then pushes
those which are descending onto "@desc", then returns @desc.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of positive real numbers, in proper Perl syntax, like so:
./ch-2.pl '([3.7, 9.2, 8.4, 13.6, 10.7],[3.9, 18.4, 78.6, 198.2, 3786.5])'

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

sub is_array_of_positive_reals ($aref) {
   return 0 unless 'ARRAY' eq ref $aref;
   for ( @$aref ) {
      return 0 unless /^[1-9]\d*(?:\.\d+)*$/;
   }
   return 1;
}

sub magical_triplets ($aref) {
   my @magical;
   my $max = 0;
   for       ( my $i = 0 ; $i <= $#$aref ; ++$i ) {
      for    ( my $j = 0 ; $j <= $#$aref ; ++$j ) {
         next if $j == $i;
         for ( my $k = 0 ; $k <= $#$aref ; ++$k ) {
            next if $k == $j || $k == $i;
            if  (   $$aref[$i] + $$aref[$j] > $$aref[$k]
                 && $$aref[$j] + $$aref[$k] > $$aref[$i]
                 && $$aref[$k] + $$aref[$i] > $$aref[$j]) {
               if ( $$aref[$i] + $$aref[$j] + $$aref[$k] > $max ) {
                  $max = $$aref[$i] + $$aref[$j] + $$aref[$k];
               }
               push(@magical, [$$aref[$i], $$aref[$j], $$aref[$k]]);
            }
         }
      }
   }
   my @max;
   for ( @magical ) {
      if ( $$_[0] + $$_[1] + $$_[2] == $max ) {
         push(@max, $_);
      }
   }
   my @desc;
   for (@max) {
      if ( $$_[0] >= $$_[1] && $$_[1] >= $$_[2] ) {
         push(@desc, $_);
      }
   }
   return @desc;
}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:

# Inputs:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   # Example 1 Input:
   [1, 2, 3, 2],
   # Expected Output: (3, 2, 2)

   # Example 2 Input:
   [1, 3, 2],
   # Expected Output: ()

   # Example 3 Input:
   [1, 1, 2, 3],
   # Expected Output: ()

   # Example 4 Input:
   [2, 4, 3],
   # Expected Output: (4, 3, 2)
);

# Main loop:
for my $aref (@arrays) {
   say '';
   say 'Array = (', join(', ', @$aref), ')';
   is_array_of_positive_reals($aref)
   or say 'Error: Not an array of positive real numbers; skipping to next array.'
   and next;
   my @triplets = magical_triplets($aref);
   my $n = scalar @triplets;
   say 'Found ', $n, ' descending maximum magical triplets', ($n ? ':' : '.');
   say '(' . join(', ', @$_) . ')' for @triplets;
}
exit;

# ------------------------------------------------------------------------------------------------------------
# DETERMINE AND PRINT EXECUTION TIME:
END {my $µs = 1000000 * (time - $t0);printf("\nExecution time was %.0fµs.\n", $µs)}
__END__
