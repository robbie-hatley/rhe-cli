#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 322-2,
written by Robbie Hatley on Dow Mon Dm, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 322-2: Rank Array
Submitted by: Mohammad Sajid Anwar
You are given an array of integers. Write a script to return an
array of the ranks of each element: the lowest value has rank 1,
next lowest rank 2, etc. If two elements are the same then they
share the same rank.

Example #1:
Input: @ints = (55, 22, 44, 33)
Output: (4, 1, 3, 2)

Example #2:
Input: @ints = (10, 10, 10)
Output: (1, 1, 1)

Example #3:
Input: @ints = (5, 1, 1, 4, 3)
Output: (4, 1, 1, 3, 2)

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

   # Given an array of numbers,
   # print corresponding array of ranks:
   sub rank_array ($aref) {
      my @sorted = sort {$a<=>$b} @$aref; # Sort number ascending.
      my $max = $sorted[0];               # Set "maximum" to first number at start.
      my $rank = 1;                       # Set rank to 1 at start.
      my %hash;                           # Make a hash of number ranks
      my @ranked;                         # Make an array for output.
      for my $item (@sorted) {            # For each number, least to greatest:
         if ($item > $max) {              # If number > max:
            $max = $item;                 # Update max
            ++$rank;                      # an jump to next-highest rank.
         }
         $hash{$item} = $rank;            # Record this number's rank in hash.
      }
      for my $item (@$aref) {             # For each number,
         push @ranked, $hash{$item};      # append its rank to @ranked .
      }
      return @ranked;                     # Return ranks.
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   # Example #1 input:
   [55, 22, 44, 33],
   # Expected output: (4, 1, 3, 2)

   # Example #2 input:
   [10, 10, 10],
   # Expected output: (1, 1, 1)

   # Example #3 input:
   [5, 1, 1, 4, 3],
   # Expected output: (4, 1, 1, 3, 2)
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   say "Array: (@$aref)";
   my @ranks = rank_array($aref);
   say "Ranks: (@ranks)";
}
