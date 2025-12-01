#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 350-1,
written by Robbie Hatley on Dow Mon Dm, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 350-1: Good Substrings
Submitted by: Mohammad Sajid Anwar

You are given a string.

Write a script to return the number of good substrings of length three in the given string.

A string is good if there are no repeated characters.


Example 1

Input: $str = "abcaefg"
Output: 5

Good substrings of length 3: abc, bca, cae, aef and efg


Example 2

Input: $str = "xyzzabc"
Output: 3

Good substrings of length 3: "xyz", "zab" and "abc"


Example 3

Input: $str = "aababc"
Output: 1

Good substrings of length 3: "abc"


Example 4

Input: $str = "qwerty"
Output: 4

Good substrings of length 3: "qwe", "wer", "ert" and "rty"


Example 5

Input: $str = "zzzaaa"
Output: 0


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
