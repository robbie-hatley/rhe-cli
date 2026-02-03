#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 359-1,
written by Robbie Hatley on Tue Feb 03, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 359-1: Digital Root
Submitted by: Mohammad Sajid Anwar

You are given a positive integer, $int.

Write a function that calculates the additive persistence of a positive integer and also return the digital root.

    Digital root is the recursive sum of all digits in a number until a single digit is obtained.

    Additive persistence is the number of times you need to sum the digits to reach a single digit.

Example 1

Input: $int = 38
Output: Persistence  = 2
        Digital Root = 2

38 => 3 + 8 => 11
11 => 1 + 1 => 2


Example 2

Input: $int = 7
Output: Persistence  = 0
        Digital Root = 7


Example 3

Input: $int = 999
Output: Persistence  = 2
        Digital Root = 9

999 => 9 + 9 + 9 => 27
27  => 2 + 7 => 9


Example 4

Input: $int = 1999999999
Output: Persistence  = 3
        Digital Root = 1

1999999999 => 1 + 9 + 9 + 9 + 9 + 9 + 9 + 9 + 9 + 9 => 82
82 => 8 + 2 => 10
10 => 1 + 0 => 1


Example 5

Input: $int = 101010
Output: Persistence  = 1
        Digital Root = 3

101010 => 1 + 0 + 1 + 0 + 1 + 0 => 3


--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
This is just a matter of performing the calculations described and seeing what one gets.

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
