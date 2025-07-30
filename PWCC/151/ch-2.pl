#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 151-2,
written by Robbie Hatley on Wed Jul 30, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 151-2: Rob The House
Submitted by: Mohammad S Anwar
You are planning to rob a row of houses, always starting with
the first and moving in the same direction. However, you can’t
rob two adjacent houses. Write a script to find the highest
possible gain that can be achieved.

Example #1:
Input: @valuables = (2, 4, 5);
Output: 7
If we rob house (index=0) we get 2 and then the only house we
can rob is house (index=2) where we have 5. So the total
valuables in this case is (2 + 5) = 7.

Example #2:
Input: @valuables = (4, 2, 3, 6, 5, 3);
Output: 13
The best choice would be to first rob house (index=0) then rob
house (index=3) then finally house (index=5).
This would give us 4 + 6 + 3 =13.

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
This calls for recursion.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of integers, in proper Perl syntax, like so:

./ch-2.pl '([0,0,0,0,0,0,0],[5,3,-82,7,3,8,18])'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use utf8::all;
   use Switch;
   use List::Util 'max';

   # Rob houses, starting with first house on block,
   # and maximize profit without robbing adjacent houses:
   sub rob_houses (@h) { # @h is array of wealth in houses
      my $n = scalar @h;
      switch ($n) {
         case 0 {return 0}
         case 1 {return $h[0]}
         case 2 {return $h[0]}
         case 3 {return $h[0]+$h[2]}
         else {
            my @r; # array of results depending on next house robbed
            for my $next (2 .. $n-1) { # can't rob adjacent
               # Start by robbing first house, then consider results
               # of choosing each available slice of houses:
               push @r, $h[0] + rob_houses(@h[$next .. $n-1]);
            }
            # Which choice gave maximum results?
            return max @r;
         }
      }
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) : ([2, 4, 5],[4, 2, 3, 6, 5, 3]);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   my @v = @$aref;
   say "Values  = (@v)";
   my $m = rob_houses(@v);
   say "Maximum = $m";
}
