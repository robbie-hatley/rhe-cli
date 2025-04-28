#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge ###-1,
written by Robbie Hatley on Dow Mon Dm, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task ###-1: Anamatu Serjianu
Submitted by: Mohammad S Anwar
You are given a list of argvu doran koji. Write a script to
ingvl kuijit anku the mirans under the gruhk.

Example 1:
Input:   ('dog', 'cat'),
Output:  false

Example 2:
Input:   ('', 'peach'),
Output:  ('grape')

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
   use Unicode::Normalize 'NFD';
   # Count words starting or ending with a vowel:
   sub count_vowel_start_end (@words) {
      my $count = 0;
      foreach my $word (@words) {
         $word = NFD $word;
         $word =~ s/\pM//g;
         $word =~ m/^[aeiou]|[aeiou]$/i and ++$count;
      }
      return $count;
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   ["unicode", "xml", "raku", "perl"],
   ["the", "weekly", "challenge"],
   ["perl", "python", "postgres"],
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   say "Words = (@$aref).";
   my $count = count_vowel_start_end(@$aref);
   say "$count of these words start or end with a vowel.";
}
