#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 365-1,
written by Robbie Hatley on Mon Mar 16, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 365-1: Alphabet Index Digit Sum
Submitted by: Mohammad Sajid Anwar

You are given a string $str consisting of lowercase English letters, and an integer $k.

Write a script to convert a lowercase string into numbers using alphabet positions (a=1 … z=26), concatenate them to form an integer, then compute the sum of its digits repeatedly $k times, returning the final value.
Example 1

Input: $str = "abc", $k = 1
Output: 6

Conversion: a = 1, b = 2, c = 3 -> 123
Digit sum: 1 + 2 + 3 = 6

Example 2

Input: $str = "az", $k = 2
Output: 9

Conversion: a = 1, z = 26 -> 126
1st sum: 1 + 2 + 6 = 9
2nd sum: 9

Example 3

Input: $str = "cat", $k = 1
Output: 6

Conversion: c = 3, a = 1, t = 20 -> 3120
Digit sum: 3 + 1 + 2 + 0 = 6

Example 4

Input: $str = "dog", $k = 2
Output: 8

Conversion: d = 4, o = 15, g = 7 -> 4157
1st sum: 4 + 1 + 5 + 7 = 17
2nd sum: 1 + 7 = 8

Example 5

Input: $str = "perl", $k = 3
Output: 6

Conversion: p = 16, e = 5, r = 18, l = 12 -> 1651812
1st sum: 1 + 6 + 5 + 1 + 8 + 1 + 2 = 24
2nd sum: 2+4 = 6
3rd sum: 6

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
   use List::Util 'sum0';

   # Index-digit-sum a string $s $n times:
   sub ids ( $s , $n ) {
      my $sum = join '', map {ord($_)-96} split //, ($s =~ s/[^a-z]//gr);
      $sum = sum0 split //, $sum for (1..$n);
      return $sum;
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) : (["abc", 1], ["az", 2], ["cat", 1], ["dog", 2], ["perl", 3]);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   my $s = $aref->[0];
   my $n = $aref->[1];
   my $m = ids($s, $n);
   say "s = $s";
   say "n = $n";
   say "m = $m";
}
