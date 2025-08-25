#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 336-2,
written by Robbie Hatley on Sun Aug 24, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 336-2: Final Score
Submitted by: Mohammad Sajid Anwar
You are given an array of scores by a team. Write a script to
find the total score of the given team. The score can be any
integer, +, C or D. The + adds the sum of previous two scores.
The score C invalidates the previous score. The score D will
double the previous score.

Example #1:
Input: @scores = ("5","2","C","D","+")
Output: 30
Round 1: 5
Round 2: 5 + 2
Round 3: 5 (invalidate the previous score 2)
Round 4: 5 + 10 (double the previous score 5)
Round 5: 5 + 10 + 15 (sum of previous two scores)
Total Scores: 30

Example #2:
Input: @scores = ("5","-2","4","C","D","9","+","+")
Output: 27
Round 1: 5
Round 2: 5 + (-2)
Round 3: 5 + (-2) + 4
Round 4: 5 + (-2) (invalidate the previous score 4)
Round 5: 5 + (-2) + (-4) (double the previous score -2)
Round 6: 5 + (-2) + (-4) + 9
Round 7: 5 + (-2) + (-4) + 9 + 5 (sum of previous two scores)
Round 8: 5 + (-2) + (-4) + 9 + 5 + 14 (sum of previous two scores)
Total Scores: 27

Example #3:
Input: @scores = ("7","D","D","C","+","3")
Output: 45
Round 1: 7
Round 2: 7 + 14 (double the previous score 7)
Round 3: 7 + 14 + 28 (double the previous score 14)
Round 4: 7 + 14 (invalidate the previous score 28)
Round 5: 7 + 14 + 21 (sum of previous two scores)
Round 6: 7 + 14 + 21 + 3
Total Scores: 45

Example #4:
Input: @scores = ("-5","-10","+","D","C","+")
Output: -55
Round 1: (-5)
Round 2: (-5) + (-10)
Round 3: (-5) + (-10) + (-15) (sum of previous two scores)
Round 4: (-5) + (-10) + (-15) + (-30) (double the previous score -15)
Round 5: (-5) + (-10) + (-15) (invalidate the previous score -30)
Round 6: (-5) + (-10) + (-15) + (-25) (sum of previous two scores)
Total Scores: -55

Example #5:
Input: @scores = ("3","6","+","D","C","8","+","D","-2","C","+")
Output: 128
Round  1: 3
Round  2: 3 + 6
Round  3: 3 + 6 + 9 (sum of previous two scores)
Round  4: 3 + 6 + 9 + 18 (double the previous score 9)
Round  5: 3 + 6 + 9 (invalidate the previous score 18)
Round  6: 3 + 6 + 9 + 8
Round  7: 3 + 6 + 9 + 8 + 17 (sum of previous two scores)
Round  8: 3 + 6 + 9 + 8 + 17 + 34 (double the previous score 17)
Round  9: 3 + 6 + 9 + 8 + 17 + 34 + (-2)
Round 10: 3 + 6 + 9 + 8 + 17 + 34 (invalidate the previous score -2)
Round 11: 3 + 6 + 9 + 8 + 17 + 34 + 51 (sum of previous two scores)
Total Scores: 128

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
This calls for a simple finite state machine.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of double-quoted strings, in proper Perl syntax, like so:

./ch-2.pl '(["rat", "bat", "cat"],["pig", "cow", "horse"])'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

use v5.36;
use utf8::all;

#
sub asdf ($x, $y) {
   -2.73*$x + 6.83*$y;
}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) : ([2.61,-8.43],[6.32,84.98]);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   my $x = $aref->[0];
   my $y = $aref->[1];
   my $z = asdf($x, $y);
   say "x = $x";
   say "y = $y";
   say "z = $z";
}
