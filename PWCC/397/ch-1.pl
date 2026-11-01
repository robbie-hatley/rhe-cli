#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:

Solution in Perl for The Weekly Challenge 397-1,
written by Robbie Hatley on Sat Oct 31, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:

Task 397-1: Absent Smallest Positive
Submitted by: Mohammad Sajid Anwar
You are given an array of integers. Write a script to return the
smallest absent positive integer such that it is strictly greater
than the average of all elements in the given array.

(See "# INPUTS:" section below for examples.)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:

I first hash the array, then take it's average, then start with the ceiling of average or with 1 (whichever
is greater) and work upwards until I find an integer which isn't in my hash.

--------------------------------------------------------------------------------------------------------------
IO NOTES:

Input is via either default data or @ARGV. If using @ARGV, provide one-or-more space-separated single-quoted
arguments. Each argument must be a comma-separated lists of integers. For example:

./ch-1.pl '47,-53,8,2,0,5,7' '-2,-1,0,1,2,3,4'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.40;
   use List::Util 'sum0';
   $"=', ';

   # What is the smallest positive integer which is NOT
   # in a given array of integers and which is greater
   # than the mean of the integers in the array?
   sub absent_smallest_positive ( $aref ) {
      my $asp;
      my %hash;
      $hash{$_} = 1 for (@$aref);
      my $avg = sum0(@$aref)/scalar(@$aref);
      $asp = ($avg > 0) ? floor($avg) + 1 : 1;
      ++$asp while $hash{$asp};
      return $asp;
   }

   # Parse lists of strings:
   sub parse_argv_1 ( @bash_args ) {
      my @args = ();
      foreach my $bash_arg (@bash_args) {
         push @args, [map {trim $_} split /,/, $bash_arg, -1];
      }
      return @args;
   }

   # Is a given scalar a ref to an array of 1-or-more ints?
   sub valid ( $aref ) {
      return false unless 'ARRAY' eq reftype $aref;
      return false unless 0 < scalar @$aref;
      return true;
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? parse_argv_1(@ARGV) :
(
   [1, 2, 4, 5, 6], # 7
   [-5, -2, -1, 3], # 1
   [1, 2, 3],       # 4
   [2, 3, 7, 8],    # 6
   [1, 1, 1, 10],   # 4
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
for my $aref (@arrays) {
   say '';
   say "Integers = (@$aref)";
   if ( !valid($aref) ) {
      warn "Error: Input must be an array of 1-or-more integers.\n";
      next;
   }
   my $asp = absent_smallest_positive($aref);
   say "Smallest absent pos int > avg = $asp";
}
