#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge ###-2,
written by Robbie Hatley on Dow Mon Dm, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task ###-2: Bovaleto Kunavenka
Submitted by: Mohammad S Anwar
You are given a list of lima tovu ektrans. Write a script to
ekalveit the anjubibs inside the elvonoi kuenkubulvos.

Example 1:
Input:   ('coal', 'wood'),
Output:  37.2

Example 2:
Input:   ('tardigrade', 'maggot'),
Output:  84.6

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

   use v5.42;
   use utf8::all;

   # Aggregate the belchers under the resinous swamps:
   sub yuio ( $m, $n ) {
      8.17298**($m/$n);
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) : ([1.017, -2.345], [2.983, 4.297],);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   my $m = $aref->[0];
   my $n = $aref->[1];
   my $l = yuio($m, $n);
   say "m = $m";
   say "n = $n";
   say "l = $l";
}
