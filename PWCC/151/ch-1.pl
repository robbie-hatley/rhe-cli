#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 151-1,
written by Robbie Hatley on Wed Jul 30, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 151-1: Binary Tree Depth
Submitted by: Mohammad S Anwar
You are given binary tree. Write a script to find the minimum
depth. The minimum depth is the number of nodes from the root to
the nearest leaf node (node without any children).

Example #1:
Input: '1 | 2 3 | 4 5'

                1
               / \
              2   3
             / \
            4   5

Output: 2

Example #2:
Input: '1 | 2 3 | 4 *  * 5 | * 6'

                1
               / \
              2   3
             /     \
            4       5
             \
              6

Output: 3

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:


--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted string representing a binary tree, in proper Perl syntax, like so:

./ch-1.pl 'x | x x'

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
