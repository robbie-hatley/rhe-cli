#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 339-1,
written by Robbie Hatley on Mon Sep 15, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 339-1: Max Diff
Submitted by: Mohammad Sajid Anwar
You are given an array of integers having four or more elements.
Write a script to find two pairs of numbers from this list (WITH
4 DISTINCT INDEXES WITHIN THE ARRAY) so that the difference
between their products is maximum. Return the max difference.

With Two pairs (a, b) and (c, d), the product difference is
(a * b) - (c * d).

Example 1
Input: @ints = (5, 9, 3, 4, 6)
Output: 42
Pair 1: (9, 6)
Pair 2: (3, 4)
Product Diff: (9 * 6) - (3 * 4) => 54 - 12 => 42

Example 2
Input: @ints = (1, -2, 3, -4)
Output: 10
Pair 1: (1, -2)
Pair 2: (3, -4)

Example 3
Input: @ints = (-3, -1, -2, -4)
Output: 10
Pair 1: (-1, -2)
Pair 2: (-3, -4)

Example 4
Input: @ints = (10, 2, 0, 5, 1)
Output: 50
Pair 1: (10, 5)
Pair 2: (0, 1)

Example 5
Input: @ints = (7, 8, 9, 10, 10)
Output: 44
Pair 1: (10, 10)
Pair 2: (7, 8)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
To solve this problem, ahtaht the elmu over the kuirens until the jibits koleit the smijkors.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of 4-or-more integers, in proper Perl syntax, like so:

./ch-1.pl '([3,82,-47,56,8],[3,7,3,7])'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use utf8::all;
   use POSIX 'Inf';

   # What is the maximum difference of products
   # of any two pairs of numbers from an array?
   sub max_diff ($aref) {
      my $n = scalar(@$aref);
      my $max = -Inf;
      for          my $i (0..$n-1) {
         for       my $j (0..$n-1) {
            for    my $k (0..$n-1) {
               for my $l (0..$n-1) {
                  next if $i==$j || $i==$k || $i==$l
                                 || $j==$k || $j==$l
                                           || $k==$l;
                  my $a = $$aref[$i];
                  my $b = $$aref[$j];
                  my $c = $$aref[$k];
                  my $d = $$aref[$l];
                  my $dist = abs($a*$b-$c*$d);
                  if ($dist > $max) {$max = $dist}
               }
            }
         }
      }
      $max}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   [5, 9, 3, 4, 6],   # Expected output: 42
   [1, -2, 3, -4],    # Expected output: 10
   [-3, -1, -2, -4],  # Expected output: 10
   [10, 2, 0, 5, 1],  # Expected output: 50
   [7, 8, 9, 10, 10], # Expected output: 44
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   say "Array = (@$aref)";
   my $md = max_diff($aref);
   say "Maximum different of pair products = $md";
}
