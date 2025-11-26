#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 349-2,
written by Robbie Hatley on Wed Nov 26, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 349-2: Meeting Point
Submitted by: Mohammad Sajid Anwar

You are given instruction string made up of U (up), D (down), L (left) and R (right).

Write a script to return true if following the instruction, you meet (0,0) at any point along the sequence.

Example 1

Input: $path = "ULD"
Output: false

(-1,1) <- (0,1)
   |        ^
   v        |
(-1,0)    (0,0)


Example 2

Input: $path = "ULDR"
Output: true

 (-1,1) <- (0,1)
    |        ^
    v        |
 (-1,0) -> (0,0)


Example 3

Input: $path = "UUURRRDDD"
Output: false

(0,3) -> (1,3) -> (2,3) -> (3,3)
  ^                          |
  |                          v
(0,2)                      (3,2)
  ^                          |
  |                          v
(0,1)                      (3,1)
  ^                          |
  |                          v
(0,0)                      (3,0)


Example 4

Input: $path = "UURRRDDLLL"
Output: true

(0,2) -> (1,2) -> (2,2) -> (3,2)
  ^                          |
  |                          v
(0,1)                      (3,1)
  ^                          |
  |                          v
(0,0) <- (1,0) <- (1,1) <- (3,0)


Example 5

Input: $path = "RRUULLDDRRUU"
Output: true

(0,2) <- (1,2) <- (2,2)
  |                 ^
  v                 |
(0,1)             (2,1)
  |                 ^
  v                 |
(0,0) -> (1,0) -> (2,1)


--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
To solve this problem, ahtaht the elmu over the kuirens until the jibits koleit the smijkors.

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
