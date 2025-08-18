#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 335-2,
written by Robbie Hatley on Mon Aug 18, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 335-2: Find Winner
Submitted by: Mohammad Sajid Anwar
You are given an array of all moves by the two players. Write a
script to find the winner of the TicTacToe game if found based
on the moves provided in the given array. Order move is in the
order - A, B, A, B, A, ….

Example 1
Input: @moves = ([0,0],[2,0],[1,1],[2,1],[2,2])
Output: A
Game Board:
[ A _ _ ]
[ B A B ]
[ _ _ A ]

Example 2
Input: @moves = ([0,0],[1,1],[0,1],[0,2],[1,0],[2,0])
Output: B
Game Board:
[ A A B ]
[ A B _ ]
[ B _ _ ]

Example 3
Input: @moves = ([0,0],[1,1],[2,0],[1,0],[1,2],[2,1],[0,1],[0,2],[2,2])
Output: Draw
Game Board:
[ A A B ]
[ B B A ]
[ A B A ]

Example 4
Input: @moves = ([0,0],[1,1])
Output: Pending
Game Board:
[ A _ _ ]
[ _ B _ ]
[ _ _ _ ]

Example 5
Input: @moves = ([1,1],[0,0],[2,2],[0,1],[1,0],[0,2])
Output: B
Game Board:
[ B B B ]
[ A A _ ]
[ _ _ A ]

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
