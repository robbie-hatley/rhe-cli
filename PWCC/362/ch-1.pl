#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 362-1,
written by Robbie Hatley on Fri Feb 27, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 362-1: Echo Chamber
Submitted by: Mohammad Sajid Anwar
You are given a string containing lowercase letters. Write a
script to transform the string based on the index position of
each character (starting from 0). For each character at
position i, repeat it i + 1 times.

Example #1:
Input: "abca"
Output: "abbcccaaaa"
Index 0: "a" -> repeated 1 time  -> "a"
Index 1: "b" -> repeated 2 times -> "bb"
Index 2: "c" -> repeated 3 times -> "ccc"
Index 3: "a" -> repeated 4 times -> "aaaa"

Example #2:
Input: "xyz"
Output: "xyyzzz"
Index 0: "x" -> "x"
Index 1: "y" -> "yy"
Index 2: "z" -> "zzz"

Example #3:
Input: "code"
Output: "coodddeeee"
Index 0: "c" -> "c"
Index 1: "o" -> "oo"
Index 2: "d" -> "ddd"
Index 3: "e" -> "eeee"

Example #4:
Input: "hello"
Output: "heelllllllooooo"
Index 0: "h" -> "h"
Index 1: "e" -> "ee"
Index 2: "l" -> "lll"
Index 3: "l" -> "llll"
Index 4: "o" -> "ooooo"

Example #5:
Input: "a"
Output: "a"
Index 0: "a" -> "a"

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
This is just a matter of doing exactly as the problem description says. I use the "x" operator to make
multiple copies of letters.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of double-quoted strings, in proper Perl syntax, like so:

./ch-1.pl '("rat", "turtle", "kangaroo", "29574")'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use utf8::all;

   # Echo Chamber:
   sub Echo ( $x ) {
      my @c = split //, $x;
      my $y;
      $y .= $c[$_]x(1+$_) for 0..$#c;
      return $y;
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @words = @ARGV ? eval($ARGV[0]) :
(
   # Example #1 input:
   "abca",
   # Expected output: "abbcccaaaa"

   # Example #2 input:
   "xyz",
   # Expected output: "xyyzzz"

   # Example #3 input:
   "code",
   # Expected output: "coodddeeee"

   # Example #4 input:
   "hello",
   # Expected output: "heelllllllooooo"

   # Example #5 input:
   "a",
   # Expected output: "a"
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $word (@words) {
   say '';
   say "Word = $word";
   my $echo = Echo($word);
   say "Echo = $echo";
}
