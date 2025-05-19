#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 322-1,
written by Robbie Hatley on Dow Mon Dm, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 322-1: String Format
Submitted by: Mohammad Sajid Anwar
You are given a string and a positive integer. Write a script to
format the string, removing any dashes, in groups of size given
by the integer. The first group can be smaller than the integer
but should have at least one character. Groups should be
separated by dashes.

Example #1:
Input: $str = "ABC-D-E-F", $i = 3
Output: "ABC-DEF"

Example #2:
Input: $str = "A-BC-D-E", $i = 2
Output: "A-BC-DE"

Example #3:
Input: $str = "-A-B-CD-E", $i = 4
Output: "A-BCDE"

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

   # Use hyphens to group the non-hyphen characters of a given string
   # in groups of a given period, with any remainder at the beginning:
   sub string_format ($aref) {
      my $raw        = $$aref[0];                                           # Raw string.
      my $period     = $$aref[1];                                           # Period.
      my $stripped   = $raw =~ s/-//gr;                                     # Chomp hyphens.
      my $remainder  = length($stripped) % $period;                         # How many leftover chars?
      my @substrings = ();                                                  # Groups of period $period.
      $remainder and push @substrings, substr $stripped, 0, $remainder, ''; # Remainder goes at beginning.
      while (length($stripped) > 0) {                                       # While we still have characters,
         push @substrings, substr $stripped, 0, $period, '';                # add groups of period $period.
      }
      join '-', @substrings;                                                # Paste substrings together w "-".
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
