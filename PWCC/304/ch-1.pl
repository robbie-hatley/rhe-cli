#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 304-1,
written by Robbie Hatley on Mon Jan 13, 2024.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 304-1: "Arrange Binary"
Submitted by: Mohammad Sajid Anwar
You are given a list @d of 0s and 1s and a positive integer $n.
Write a script to return true if you can re-arrange the list by
replacing at least $n "0" digits of @d with "1" in such a way
that no two consecutive digits are 1, otherwise return false.

Example #1:
Input: @digits = (1, 0, 0, 0, 1), $n = 1
Output: true
Re-arranged list: (1, 0, 1, 0, 1)

Example #2:
Input: @digits = (1, 0, 0, 0, 1), $n = 2
Output: false

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
To solve this problem, ahtaht the elmu over the kuirens until the jibits koleit the smijkors.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of double-quoted strings, apostrophes escaped as '"'"', in proper Perl syntax:
./ch-1.pl '(["She shaved?", "She ate 7 hot dogs."],["She didn'"'"'t take baths.", "She sat."])'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

use v5.36;



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
