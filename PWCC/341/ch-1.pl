#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 341-1,
written by Robbie Hatley on Mon Sep 29, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 341-1: Broken Keyboard
Submitted by: Mohammad Sajid Anwar
You are given a string containing English letters only, and you
are given a list of broken keys. Write a script to return the
total words in the given sentence can be typed completely.

Example #1:
Input: $str = 'Hello World', @keys = ('d')
Output: 1
With broken key 'd', we can only type the word 'Hello'.

Example #2:
Input: $str = 'apple banana cherry', @keys = ('a', 'e')
Output: 0

Example #3:
Input: $str = 'Coding is fun', @keys = ()
Output: 3
No keys broken.

Example #4:
Input: $str = 'The Weekly Challenge', @keys = ('a','b')
Output: 2

Example #5:
Input: $str = 'Perl and Python', @keys = ('p')
Output: 1

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
I'll join the broken keys into a string $broken, then interpolate $broken into a regular expression character
class, then case-insensitively match incoming words against that regexp and push non-matching words to array
@allowed, then return the scalar of @allowed.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of a double-quoted string followed by an array of double-quoted single-character
strings, in proper Perl syntax, like so:

./ch-1.pl '(["I see a {big} rat!", ["]", "[", "t"]],["James [ate] a crow!", ["c", "o", "w"]])'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use utf8::all;

   # How many words of a given string can
   # we type, given a list of bad keys?
   sub allowed_words ($str, @keys) {
      my @words = split /\s+/, $str;
      return scalar(@words) if 0 == scalar(@keys);
      my $forbidden = join '', @keys;
      my @allowed;
      for (@words) {
         if ($_ !~ m/[\Q$forbidden\E]/i) {
            push @allowed, $_}}
      scalar @allowed}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   # Example #1 input:
   ['Hello World', ['d']],
   # Expected output: 1

   # Example #2 input:
   ['apple banana cherry', ['a', 'e']],
   # Expected output: 0

   # Example #3 input:
   ['Coding is fun', []],
   # Expected output: 3

   # Example #4 input:
   ['The Weekly Challenge', ['a','b']],
   # Expected output: 2

   # Example #5 input:
   ['Perl and Python', ['p']],
   # Expected output: 1
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=' ';
say "Caveat: May give wrong answers if any non-alpha keys are broken.";
for my $aref (@arrays) {
   say '';
   my $str  = $aref->[0];
   my @keys = @{$aref->[1]};
   my $allowed = allowed_words($str, @keys);
   say "String = $str";
   say "Bad keys = @keys";
   say "Number of words we can type = $allowed"}
