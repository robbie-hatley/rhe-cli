#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 362-2,
written by Robbie Hatley on Fri Feb 21, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 362-2: Spellbound Sorting
Submitted by: Peter Campbell Smith

You are given an array of integers.

Write a script to return them in alphabetical order, in any language of your choosing. Default language is English.
Example 1

Input: (6, 7, 8, 9 ,10)
Output: (8, 9, 7, 6, 10)

eight, nine, seven, six, ten


Example 2

Input: (-3, 0, 1000, 99)
Output: (-3, 99, 1000, 0)

minus three, ninety-nine, one thousand, zero


Example 3

Input: (1, 2, 3, 4, 5)

Output: (5, 2, 4, 3, 1) for French language
cinq, deux, quatre, trois, un

Output: (5, 4, 1, 3, 2) for English language
five, four, one, three, two


Example 4

Input: (0, -1, -2, -3, -4)
Output: (-4, -1, -3, -2, 0)

minus four, minus one, minus three, minus two, zero


Example 5

Input: (100, 101, 102)
Output: (100, 101, 102)

one hundred, one hundred and one, one hundred and two


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
