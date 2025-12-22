#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 353-2,
written by Robbie Hatley on Mon Dec 22, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 353-2: Validate Coupon
Submitted by: Mohammad Sajid Anwar

You are given three arrays, @codes, @names and @status.

Write a script to validate codes in the given array.

A code is valid when the following conditions are true:
- codes[i] is non-empty and consists only of alphanumeric characters (a-z, A-Z, 0-9) and underscores (_).
- names[i] is one of the following four categories: "electronics", "grocery", "pharmacy", "restaurant".
- status[i] is true.

Return an array of booleans indicating validity: output[i] is true if and only if codes[i], names[i] and status[i] are all valid.
Example 1

Input: @codes  = ("A123", "B_456", "C789", "D@1", "E123")
       @names  = ("electronics", "restaurant", "electronics", "pharmacy", "grocery")
       @status = ("true", "false", "true", "true", "true")
Output: (true, false, true, false, true)


Example 2

Input: @codes  = ("Z_9", "AB_12", "G01", "X99", "test")
       @names  = ("pharmacy", "electronics", "grocery", "electronics", "unknown")
       @status = ("true", "true", "false", "true", "true")
Output: (true, true, false, true, false)


Example 3

Input: @codes  = ("_123", "123", "", "Coupon_A", "Alpha")
       @names  = ("restaurant", "electronics", "electronics", "pharmacy", "grocery")
       @status = ("true", "true", "false", "true", "true")
Output: (true, true, false, true, true)


Example 4

Input: @codes  = ("ITEM_1", "ITEM_2", "ITEM_3", "ITEM_4")
       @names  = ("electronics", "electronics", "grocery", "grocery")
       @status = ("true", "true", "true", "true")
Output: (true, true, true, true)


Example 5

Input: @codes  = ("CAFE_X", "ELEC_100", "FOOD_1", "DRUG_A", "ELEC_99")
       @names  = ("restaurant", "electronics", "grocery", "pharmacy", "electronics")
       @status = ("true", "true", "true", "true", "false")
Output: (true, true, true, true, false)


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
