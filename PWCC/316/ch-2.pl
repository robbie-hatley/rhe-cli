#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 316-2,
written by Robbie Hatley on Mon Apr 7, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 316-2: Subsequence
Submitted by: Mohammad Sajid Anwar
You are given two strings. Write a script to find out if one
string is a subsequence of another. (A "subsequence" of a string
is a new string that is formed from the original string by
deleting some (can be none) of the characters without disturbing
the relative positions of the remaining characters.

Example #1:
Input: $str1 = "uvw", $str2 = "bcudvew"
Output: true

Example #2:
Input: $str1 = "aec", $str2 = "abcde"
Output: false

Example #3:
Input: $str1 = "sip", $str2 = "javascript"
Output: true

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
Clearly, a string S1 can't be a subsequence of a string S2 if S1 is longer than S2. So I'll start by comparing
lengths. There will be 3 possibilities:
switch (length($S1) <=> length($S2)) {
   case -1 {see if $S1 can be made from $S2 by character deletion}
   case  0 {if strings are identical, they're both subsequences; else, neither is.}
   case  1 {see if $S2 can be made from $S1 by character deletion}
}

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of double-quoted strings, apostrophes escaped as '"'"', in proper Perl syntax:
./ch-2.pl '(["She shaved?", "She ate 7 hot dogs."],["She didn'"'"'t take baths.", "She sat."])'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use utf8;
   use utf8::all;

   # Is one of two strings a subsequence of the other?
   sub subsequence ($S1, $S2) {
      # Put the two strings in the order shorter, longer:
      my ($shrt, $long) = sort {length($a) <=> length($b)} ($S1, $S2);

   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   #Example #1 input:
   ["uvw", "bcudvew"],
   # Expected output: true

   #Example #2 input:
   ["aec", "abcde"],
   # Expected output: false

   #Example #3 input:
   ["sip", "javascript"],
   # Expected output: true
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   my $S1 = $aref->[0];
   my $S2 = $aref->[1];
   say(subsequence($S1,$S2));
}
