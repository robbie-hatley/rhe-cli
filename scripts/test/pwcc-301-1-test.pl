#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
TEST ROUTINES for The Weekly Challenge 301-1,
written by Robbie Hatley on Tue Dec 24, 2024.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 301-1: Largest Number
Submitted by: Mohammad Sajid Anwar
You are given a list of positive integers, @ints. Write a script
to arrange all the elements in the given list such that they form
the largest number and return it.

Example #1:
Input: @ints = (20, 3)
Output: 320

Example #2:
Input: @ints = (3, 30, 34, 5, 9)
Output: 9534330

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
While it's tempting to just "sort and join", while that would work with some numbers (eg, Example #1), it
wouldn't work with others (eg, Example #2). So I'll use the non-OOP "permute" function from my favorite CPAN
module, "Math::Combinatorics", to get all permutations, join each, and see which is greatest. (I'm sure there
are ways of doing this with smaller big-O, but I've got other things to do this week, so I'll go for the
Godzilla smash instead of the surgical precision.)

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of positive integers, in proper Perl syntax, like so:
./301-1-test.pl '([3,8,437,2264,73894],[3,23,9,385,4298],[29,11,286,37,87,1935,30,285,537,61])'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use Math::Combinatorics;

   sub largest1 (@nums) {
      my @perms = permute @nums;
      my $max = 0;
      foreach my $perm (@perms) {
         my $num = join '', @$perm;
         if ($num gt $max) {$max = $num}
      }
      return $max;
   }

   sub largest2 (@nums) {
      join '', sort {$b.$a cmp $a.$b} @nums;
   }

   sub largest3 (@nums) {
      join '', sort {$b.$a <=> $a.$b} @nums;
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays;
foreach my $i (1..1000) {
   my @array;
   my $lim = 5 + int rand(5);
   foreach my $j (1..$lim){
      push @array, int 10**rand(6);
   }
   push @arrays, [@array];
}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   #say '';
   my @numbers = @$aref;
   #say "Numbers = (@numbers)";
   my $largest1 = largest1(@numbers);
   #say "Largest Combined Number (method 1) = $largest1";
   my $largest2 = largest2(@numbers);
   #say "Largest Combined Number (method 2) = $largest2";
   my $largest3 = largest3(@numbers);
   #say "Largest Combined Number (method 3) = $largest3";
   if ($largest1 ne $largest2) {say "DISAGREE BETWEEN LARGEST1 AND LARGEST2!"}
   if ($largest2 ne $largest3) {say "DISAGREE BETWEEN LARGEST2 AND LARGEST3!"}
   if ($largest3 ne $largest1) {say "DISAGREE BETWEEN LARGEST3 AND LARGEST1!"}
}
