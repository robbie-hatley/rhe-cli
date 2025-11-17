#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 348-2,
written by Robbie Hatley on Mon Nov 17, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 348-2: Covert Time
Submitted by: Mohammad Sajid Anwar

You are given two strings, $source and $target, containing time in 24-hour time form.

Write a script to convert the source into target by performing one of the following operations:

1. Add  1 minute
2. Add  5 minutes
3. Add 15 minutes
4. Add 60 minutes

Find the total operations needed to get to the target.

Example 1

Input: $source = "02:30"
       $target = "02:45"
Output: 1

Just one operation i.e. "Add 15 minutes".


Example 2

Input: $source = "11:55"
       $target = "12:15"
Output: 2

Two operations i.e. "Add 15 minutes" followed by "Add 5 minutes".


Example 3

Input: $source = "09:00"
       $target = "13:00"
Output: 4

Four operations of "Add 60 minutes".


Example 4

Input: $source = "23:45"
       $target = "00:30"
Output: 3

Three operations of "Add 15 minutes".


Example 5

Input: $source = "14:20"
       $target = "15:25"
Output: 2

Two operations, one "Add 60 minutes" and one "Add 5 minutes"

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
