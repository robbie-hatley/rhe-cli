#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 356-1,
written by Robbie Hatley on Dow Mon Dm, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 356-1: Kolakoski Sequence
Submitted by: Mohammad Sajid Anwar
You are given an integer, $int > 3.

Write a script to generate the Kolakoski Sequence of given length $int and return the count of 1 in the generated sequence. Please follow the wikipedia page for more informations.
Example 1

Input: $int = 4
Output: 2

(1)(22)(11)(2) => 1221


Example 2

Input: $int = 5
Output: 3

(1)(22)(11)(2)(1) => 12211


Example 3

Input: $int = 6
Output: 3

(1)(22)(11)(2)(1)(22) => 122112


Example 4

Input: $int = 7
Output: 4

(1)(22)(11)(2)(1)(22)(1) => 1221121


Example 5

Input: $int = 8
Output: 4

(1)(22)(11)(2)(1)(22)(1)(22) => 12211212

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
