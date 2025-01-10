#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 303-2,
written by Robbie Hatley on Wed Jan 08, 2024.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 303-2: Delete and Earn
Submitted by: Mohammad Sajid Anwar
You are given an array of integers, @ints. Write a script to
return the maximum number of points you can earn by applying
the following operation some number of times:
Pick any ints[i] and delete it to earn ints[i] points.
Afterwards, you must delete every element equal to
(ints[i] - 1) and every element equal to (ints[i] + 1).

Example #1:
Input: @ints = (3, 4, 2)
Output: 6
Delete 4 to earn 4 points. (Also delete all 3s and 5s.)
Finally delete 2 to earn 2 points.

Example #2:
Input: @ints = (2, 2, 3, 3, 3, 4)
Output: 9
Delete a 3 to earn 3 points. (Also delete all 2s and 4s.)
Delete a 3 again to earn 3 points.
Delete a 3 once more to earn 3 points.

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
To solve this problem, ahtaht the elmu over the kuirens until the jibits koleit the smijkors.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of double-quoted strings, apostrophes escaped as '"'"', in proper Perl syntax:
./ch-2.pl '(["She shaved?", "She ate 7 hot dogs."],["She didn'"'"'t take baths.", "She sat."])'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

use v5.38;
use utf8;
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
