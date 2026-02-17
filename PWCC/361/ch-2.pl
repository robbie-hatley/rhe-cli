#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 361-2,
written by Robbie Hatley on Dow Mon Dm, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 361-2: Find Celebrity
Submitted by: Mohammad Sajid Anwar

You are given a binary matrix (m x n).

Write a script to find the celebrity, return -1 when none found.

A celebrity is someone, everyone knows and knows nobody.

Example 1

Input: @party = (
   [0, 0, 0, 0, 1, 0],  # 0 knows 4
   [0, 0, 0, 0, 1, 0],  # 1 knows 4
   [0, 0, 0, 0, 1, 0],  # 2 knows 4
   [0, 0, 0, 0, 1, 0],  # 3 knows 4
   [0, 0, 0, 0, 0, 0],  # 4 knows NOBODY
   [0, 0, 0, 0, 1, 0],  # 5 knows 4
   );
   Output: 4


   Example 2

   Input: @party = (
      [0, 1, 0, 0],  # 0 knows 1
      [0, 0, 1, 0],  # 1 knows 2
      [0, 0, 0, 1],  # 2 knows 3
      [1, 0, 0, 0]   # 3 knows 0
      );
      Output: -1


      Example 3

      Input: @party = (
         [0, 0, 0, 0, 0],  # 0 knows NOBODY
         [1, 0, 0, 0, 0],  # 1 knows 0
         [1, 0, 0, 0, 0],  # 2 knows 0
         [1, 0, 0, 0, 0],  # 3 knows 0
         [1, 0, 0, 0, 0]   # 4 knows 0
         );
         Output: 0


         Example 4

         Input: @party = (
            [0, 1, 0, 1, 0, 1],  # 0 knows 1, 3, 5
            [1, 0, 1, 1, 0, 0],  # 1 knows 0, 2, 3
            [0, 0, 0, 1, 1, 0],  # 2 knows 3, 4
            [0, 0, 0, 0, 0, 0],  # 3 knows NOBODY
            [0, 1, 0, 1, 0, 0],  # 4 knows 1, 3
            [1, 0, 1, 1, 0, 0]   # 5 knows 0, 2, 3
            );
            Output: 3


            Example 5

            Input: @party = (
               [0, 1, 1, 0],  # 0 knows 1 and 2
               [1, 0, 1, 0],  # 1 knows 0 and 2
               [0, 0, 0, 0],  # 2 knows NOBODY
               [0, 0, 0, 0]   # 3 knows NOBODY
               );
               Output: -1


               Example 6

               Input: @party = (
                  [0, 0, 1, 1],  # 0 knows 2 and 3
                  [1, 0, 0, 0],  # 1 knows 0
                  [1, 1, 0, 1],  # 2 knows 0, 1 and 3
                  [1, 1, 0, 0]   # 3 knows 0 and 1
                  );
                  Output: -1


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
