#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 361-1,
written by Robbie Hatley on Dow Mon Dm, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 361-1: Zeckendorf Representation
Submitted by: Mohammad Sajid Anwar
You are given a positive integer (<= 100). Write a script to
return Zeckendorf Representation of the given integer.
Every positive integer can be uniquely represented as sum of
non-consecutive Fibonacci numbers.

Example 1
Input: $int = 4
Output: 3,1
4 => 3 + 1 (non-consecutive fibonacci numbers)

Example 2
Input: $int = 12
Output: 8,3,1
12 => 8 + 3 + 1

Example 3
Input: $int = 20
Output: 13,5,2
20 => 13 + 5 + 2

Example 4
Input: $int = 96
Output: 89,5,2
96 => 89 + 5 + 2

Example 5
Input: $int = 100
Output: 89,8,3
100 => 89 + 8 + 3

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
To solve this problem, ahtaht the elmu over the kuirens until the jibits koleit the smijkors.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of double-quoted strings, in proper Perl syntax, like so:

./ch-1.pl '(["rat", "bat", "cat"],["pig", "cow", "horse"])'

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
