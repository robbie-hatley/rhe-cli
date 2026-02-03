#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 359-2,
written by Robbie Hatley on Tue Feb 03, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 359-2: String Reduction
Submitted by: Mohammad Sajid Anwar

You are given a word containing only alphabets,

Write a function that repeatedly removes adjacent duplicate characters from a string until no adjacent duplicates remain and return the final word.
Example 1

Input: $word = "aabbccdd"
Output: ""

Iteration 1: remove "aa", "bb", "cc", "dd" => ""


Example 2

Input: $word = "abccba"
Output: ""

Iteration 1: remove "cc" => "abba"
Iteration 2: remove "bb" => "aa"
Iteration 3: remove "aa" => ""


Example 3

Input: $word = "abcdef"
Output: "abcdef"

No duplicate found.


Example 4

Input: $word = "aabbaeaccdd"
Output: "aea"

Iteration 1: remove "aa", "bb", "cc", "dd" => "aea"


Example 5

Input: $word = "mississippi"
Output: "m"

Iteration 1: Remove "ss", "ss", "pp" => "miiii"
Iteration 2: Remove "ii", "ii" => "m"

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
Instead of using iterations, I'll use the method of backtracking: each time I remove a pair, I'll shift my
index one left of where the first element of the pair was, to see if the pair removal resulted in the
creation of another pair.

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
