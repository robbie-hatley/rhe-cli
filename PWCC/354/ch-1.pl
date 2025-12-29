#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 354-1,
written by Robbie Hatley on Mon Dec 29, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 354-1: Min Abs Diff
Submitted by: Mohammad Sajid Anwar

You are given an array of distinct integers.

Write a script to find all pairs of elements with the minimum absolute difference.

Rules (a,b):
1: a, b are from the given array.
2: a < b
3: b - a = min abs diff any two elements in the given array

Example 1

Input: @ints= (4, 2, 1, 3)
Output: [1, 2], [2, 3], [3, 4]


Example 2

Input: @ints = (10, 100, 20, 30)
Output: [10, 20], [20, 30]


Example 3

Input: @ints = (-5, -2, 0, 3)
Output: [-2, 0]


Example 4

Input: @ints = (8, 1, 15, 3)
Output: [1, 3]


Example 5

Input: @ints = (12, 5, 9, 1, 15)
Output: [9, 12], [12, 15]


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
use List::Util 'min';

# Min Abs Diff:
sub mad ( $aref ) {
   my %pairs;
   my $n = scalar(@$aref);
   foreach my $i (0..$n-2) {
      my $x = $$aref[$i];
      foreach my $j ($i+1..$n-1) {
         my $y = $$aref[$j];
         my $dist = abs($x-$y);
         push @{$pairs{$dist}}, [sort {$a<=>$b} ($x, $y)];
      }
   }
   @{$pairs{min keys %pairs}};
}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   # Example 1
   [4, 2, 1, 3],
   # Output: [1, 2], [2, 3], [3, 4]

   # Example 2
   [10, 100, 20, 30],
   # Output: [10, 20], [20, 30]

   # Example 3
   [-5, -2, 0, 3],
   # Output: [-2, 0]

   # Example 4
   [8, 1, 15, 3],
   # Output: [1, 3]

   # Example 5
   [12, 5, 9, 1, 15],
   # Output: [9, 12], [12, 15]
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   my @mad = mad($aref);
   say join ', ', map {"[@$_]"} sort {$$a[0]<=>$$b[0]} @mad;
}
