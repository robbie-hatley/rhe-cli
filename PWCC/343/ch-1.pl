#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 343-1,
written by Robbie Hatley on Wed Oct 15, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 343-1: AZero Friend
Submitted by: Mohammad Sajid Anwar
You are given a list of numbers. Find the number that is closest
to zero and return its distance to zero.

Example 1
Input: @nums = (4, 2, -1, 3, -2)
Output: 1
Values closest to 0: -1 and 2 (distance = 1 and 2)

Example 2
Input: @nums = (-5, 5, -3, 3, -1, 1)
Output: 1
Values closest to 0: -1 and 1 (distance = 1)

Example 3
Input: @ums = (7, -3, 0, 2, -8)
Output: 0
Values closest to 0: 0 (distance = 0)
Exact zero wins regardless of other close values.

Example 4
Input: @nums = (-2, -5, -1, -8)
Output: 1
Values closest to 0: -1 and -2 (distance = 1 and 2)

Example 5
Input: @nums = (-2, 2, -4, 4, -1, 1)
Output: 1
Values closest to 0: -1 and 1 (distance = 1)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
To solve this problem, I'll make an array which is an ascending numeric sort of the absolute values of the
given numbers, then return the 0th element of that array.

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
