#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 326-2,
written by Robbie Hatley on Tue Jun 17, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 326-2: Decompressed List
Submitted by: Mohammad Sajid Anwar
You are given an array of positive integers having even elements.
Write a script to to return the decompress list. To decompress,
pick adjacent pair (i, j) and replace it with j, i times.

Example #1:
Input: @ints = (1, 3, 2, 4)
Output: (3, 4, 4)
Pair 1: (1, 3) => 3 one time  => (3)
Pair 2: (2, 4) => 4 two times => (4, 4)

Example #2:
Input: @ints = (1, 1, 2, 2)
Output: (1, 2, 2)
Pair 1: (1, 1) => 1 one time  => (1)
Pair 2: (2, 2) => 2 two times => (2, 2)

Example #3:
Input: @ints = (3, 1, 3, 2)
Output: (1, 1, 1, 2, 2, 2)
Pair 1: (3, 1) => 1 three times => (1, 1, 1)
Pair 2: (3, 2) => 2 three times => (2, 2, 2)

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
