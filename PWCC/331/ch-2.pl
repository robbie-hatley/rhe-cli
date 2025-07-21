#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 331-2,
written by Robbie Hatley on Dow Mon Dm, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 331-2: Buddy Strings
Submitted by Mohammad Sajid Anwar. Edited by Robbie Hatley for
family-friendliness.

You are given two strings, source and target. Write a script to
find out if the given strings are Buddy Strings. If swapping of
a letter in one string make them same as the other then they
are "Buddy Strings".

Example #1:
Input: $source = "farm"
       $target = "fram"
Output: true
The swapping of 'a' with 'r' makes it buddy strings.

Example #2:
Input: $source = "love"
       $target = "love"
Output: false

Example #3:
Input: $source = "fodo"
       $target = "food"
Output: true

Example #4:
Input: $source = "feed"
       $target = "feed"
Output: true

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:


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
