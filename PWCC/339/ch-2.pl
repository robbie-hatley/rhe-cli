#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 339-2,
written by Robbie Hatley on Mon Sep 15, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 339-2: Peak Point
Submitted by: Mohammad Sajid Anwar
You are given an array of altitude changes. Write a script to
find the maximum altitude attained, assuming that one starts
at altitude 0.

Example 1
Input:  [-5, 1, 5, -9, 2]
Output: 1


Example 2
Input:  [10, 10, 10, -25]
Output: 30

Example 3
Input:  [3, -4, 2, 5, -6, 1]
Output: 6

Example 4
Input:  [-1, -2, -3, -4]
Output: 0

Example 5
Input:  [-10, 15, 5]
Output: 10

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
I'll keep track of "current" and and "max" altitudes reached after each change, then return max.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of numbers, in proper Perl syntax, like so:

./ch-2.pl '([-35.2, 38.7, -14.9, 13.9],[1,2,3,4,-1,-2,-3,-4])'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use utf8::all;

   # What is the total altitude change?
   sub total_altitude_change ($aref) {
      my $cur_alt = 0;
      my $max_alt = 0;
      for my $change (@$aref) {
         $cur_alt += $change;
         if ($cur_alt > $max_alt) {$max_alt = $cur_alt}
      }
      $max_alt}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   [-5, 1, 5, -9, 2]    , # Expected output: 1
   [10, 10, 10, -25]    , # Expected output: 30
   [3, -4, 2, 5, -6, 1] , # Expected output: 6
   [-1, -2, -3, -4]     , # Expected output: 0
   [-10, 15, 5]         , # Expected output: 10
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   say "Altitude changes = (@$aref)";
   my $tac = total_altitude_change($aref);
   say "Maximum altitude = $tac";
}
