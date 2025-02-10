#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

--------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
Solutions in Perl for The Weekly Challenge 236-2.
Written by Robbie Hatley on Fri Oct 06, 2023.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 2: Array Loops
Submitted by: Mark Anderson
You are given an array of unique integers. Write a script to
determine how many loops are in the given array. To determine
a loop: Start at an index and take the number at array[index]
and then proceed to that index and continue this until you end up
at the starting index.

Example 1:
Input: @ints = (4,6,3,8,15,0,13,18,7,16,14,19,17,5,11,1,12,2,9,10)
Output: 3
To determine the 1st loop, start at index 0, the number at that
index is 4, proceed to index 4, the number at that index is 15,
proceed to index 15 and so on until you're back at index 0.
Loops are as below:
[4 15 1 6 13 5 0]
[3 8 7 18 9 16 12 17 2]
[14 11 19 10]

Example 2:
Input: @ints = (0,1,13,7,6,8,10,11,2,14,16,4,12,9,17,5,3,18,15,19)
Output: 6
Loops are as below:
[0]
[1]
[13 9 14 17 18 15 5 8 2]
[7 11 4 6 10 16 3]
[12]
[19]

Example 3:
Input: @ints = (9,8,3,11,5,7,13,19,12,4,14,10,18,2,16,1,0,15,6,17)
Output: 1
Loop is as below:
[9 4 5 7 19 17 15 1 8 12 18 6 13 2 3 11 10 14 16 0]

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
I think I'll just take the indices in order from 0 through $#ints and see if a "loop" (that is, a
self-referential cycle with an inbound reference to its own begin point) can be formed at each one.
If we don't get back to our start point in scalar(@ints) tries, we never will, because that would
mean either we've visited every element at least once and none point back to the origin, or we got
caught in a cycle other than a loop, or we hit an element who's value points out of the array.

I'll have to find a way, though, to avoid duplicating every loop on each of its vertices. I think I'll mark
each array position with an "o" to begin with, then mark each position with "x" the first time each position
is visited. Starting at each index in-turn, if we end up hopping to an x, don't count that path as a "loop".

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of unique integers in proper Perl syntax, like so:
./ch-2.pl "([1,0,4,5,7,3,2,6],[-2,0,18,7,63,14])"

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

sub loops ($aref) {
   my @loops; # Array of loops.
   my @visited = ('o') x scalar(@$aref);
   START: for ( my $i = 0 ; $i <= $#$aref ; ++$i ) {
      my @path = (); # Path from this START point.
      HOP: for ( my $hops = 0, my $j = $$aref[$i] ; $hops < scalar(@$aref) ; ++ $hops, $j = $$aref[$j] ) {
         if ( 'x' eq $visited[$j] ) {
            # Old loop, new starting point, so don't increment "$loops" here.
            next START;
         }
         # THIS element has just been freshly visited right now,
         # so record it in @path and so mark it "x":
         push @path, $j;
         $visited[$j] = 'x';
         if ( $j == $i ) {
            # If we get to here, we just closed a new loop, so push this path onto @loops:
            push @loops, [@path];
            next START;
         }
      }
   }
   return @loops;
}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:

# Inputs:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   [4,6,3,8,15,0,13,18,7,16,14,19,17,5,11,1,12,2,9,10],
   [0,1,13,7,6,8,10,11,2,14,16,4,12,9,17,5,3,18,15,19],
   [9,8,3,11,5,7,13,19,12,4,14,10,18,2,16,1,0,15,6,17],
);

# Main loop:
for my $aref (@arrays) {
   my @loops = loops($aref);
   say '';
   say 'Array = (', join(', ', @$aref), ')';
   say 'Number of loops = ', scalar(@loops), ':';
   for ( @loops ) {
      say '(', join(', ', @$_), ')';
   }
}
exit;

# ------------------------------------------------------------------------------------------------------------
# DETERMINE AND PRINT EXECUTION TIME:
END {my $µs = 1000000 * (time - $t0); printf("\nExecution time was %.0fµs.\n", $µs)}
__END__
