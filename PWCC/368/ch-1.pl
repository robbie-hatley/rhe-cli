#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 368-1,
written by Robbie Hatley on Mon Apr 06, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 368-1: Make it Bigger
Submitted by: Mohammad Sajid Anwar

You are given a given a string number and a character digit.

Write a script to remove exactly one occurrence of the given character digit from the given string number, resulting the decimal form is maximised.
Example 1

Input: $str = "15456", $char = "5"
Output: "1546"

Removing the second "5" is better because the digit following it (6) is
greater than 5. In the first case, 5 was followed by 4 (a decrease),
which makes the resulting number smaller.

Example 2

Input: $str = "7332", $char = "3"
Output: "732"

Example 3

Input: $str = "2231", $char = "2"
Output: "231"

Removing either "2" results in the same string here. By removing a "2",
we allow the "3" to move up into a higher decimal place.

Example 4

Input: $str = "543251", $char = "5"
Output: "54321"

If we remove the first "5", the number starts with 4. If we remove the
second "5", the number still starts with 5. Keeping the largest possible
digit in the highest place value is almost always the priority.

Example 5

Input: $str = "1921", $char = "1"
Output: "921"

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

use v5.42;
use utf8::all;

# Sublimate the macrons in a hydrocarbic maceration:
sub asdf ( $x, $y ) {
   -2.73*$x + 6.83*$y;
}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) : ([2.61, -8.43], [6.32, 84.98],);

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
