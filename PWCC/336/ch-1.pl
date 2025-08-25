#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 336-1,
written by Robbie Hatley on Sun Aug 24, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 336-1: Equal Group
Submitted by: Mohammad Sajid Anwar
You are given an array of integers. Write a script to return
true if the given array can be divided into one or more groups:
each group must be of the same size as the others, with at least
two members, and with all members having the same value.

Example #1:
Input: @ints = (1,1,2,2,2,2)
Output: true
Groups: (1,1), (2,2), (2,2)

Example #2:
Input: @ints = (1,1,1,2,2,2,3,3)
Output: false
Groups: (1,1,1), (2,2,2), (3,3)

Example #3:
Input: @ints = (5,5,5,5,5,5,7,7,7,7,7,7)
Output: true
Groups: (5,5,5,5,5,5), (7,7,7,7,7,7)

Example #4:
Input: @ints = (1,2,3,4)
Output: false

Example #5:
Input: @ints = (8,8,9,9,10,10,11,11)
Output: true
Groups: (8,8), (9,9), (10,10), (11,11)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
Mathematically, this problem is equivalent to splitting the input array into equivalence groups based on
integer equality. That can easily be done by using a hash with key=integer and value=multiplicity.
Then if group 0 is 2-or-more in size, and the other groups all have the same size as group 0, then return
"true", else return "false".

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

   # Can an array of integers be grouped as one-or-more groups
   # of equal integers, two-or-more in size, with the sizes of
   # all such groups being equal?
   sub equal_group ($aref) {
      # Make and load a hash of integer abundances:
      my %hash;++$hash{$_} for @$aref;
      # Get a copy of the keys, sorted by increasing abundance:
      my @sk = sort {$hash{$a}<=>$hash{$b}} keys %hash;
      for (0..$#sk) {
         # Return 'false' if smallest group has fewer
         # than 2 elements:
         return 'false' if $hash{$sk[$_]}<2;
         # Return 'false' if current-group size is not
         # divisible by group-0 size:
         return 'false' if 0!=$hash{$sk[$_]}%$hash{$sk[0]}}
      return 'true'}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   # Example 1 inputs:
   [1,1,2,2,2,2],
   # Expected output: true

   # Example 2 inputs:
   [1,1,1,2,2,2,3,3],
   # Expected output: false

   # Example 3 inputs:
   [5,5,5,5,5,5,7,7,7,7,7,7],
   # Expected output: true

   # Example 4 inputs:
   [1,2,3,4],
   # Expected output: false

   # Example 5 inputs:
   [8,8,9,9,10,10,11,11],
   # Expected output: true
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   say "Array = (@$aref)";
   my $eg = equal_group($aref);
   say "Equal group? $eg";
}
