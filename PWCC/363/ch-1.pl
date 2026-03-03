#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 363-1,
written by Robbie Hatley on Mon Mar 2, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 363-1: String Lie Detector
Submitted by: Mohammad Sajid Anwar
You are given a string. Write a script that parses a
self-referential string and determines whether its claims about
itself are true. The string will make statements about its own
composition, specifically the number of vowels and consonants
it contains.

(
   # Example #1 input:
   "aa — two vowels and zero consonants",
   # Expected output: true

   # Example #2 input:
   "iv — one vowel and one consonant",
   # Expected output: true

   # Example #3 input:
   "hello - three vowels and two consonants",
   # Expected output: false

   # Example #4 input:
   "aeiou — five vowels and zero consonants",
   # Expected output: true input:

   # Example #5 input:
   "aei — three vowels and zero consonants",
   # Expected output: true
);

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
