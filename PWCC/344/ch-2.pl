#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 344-2,
written by Robbie Hatley on Wed Oct 22, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 344-2:Array Formation
Submitted by: Mohammad Sajid Anwar

You are given two list: @source and @target.

Write a script to see if you can build the exact @target by
putting these smaller lists from @source together in some order.
You cannot break apart or change the order inside any of the
smaller lists in @source.

Example 1
Input: @source = ([2,3], [1], [4])
       @target = (1, 2, 3, 4)
Output: true
Use in the order: [1], [2,3], [4]

Example 2
Input: @source = ([1,3], [2,4])
       @target = (1, 2, 3, 4)
Output: false

Example 3
Input: @source = ([9,1], [5,8], [2])
       @target = (5, 8, 2, 9, 1)
Output: true
Use in the order: [5,8], [2], [9,1]

Example 4
Input: @source = ([1], [3])
       @target = (1, 2, 3)
Output: false
Missing number: 2

Example 5
Input: @source = ([7,4,6])
       @target = (7, 4, 6)
Output: true
Use in the order: [7, 4, 6]

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
