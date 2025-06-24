#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 327-2,
written by Robbie Hatley on Mon Jun 23, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 327-2: MAD
Submitted by: Mohammad Sajid Anwar
You are given an array of distinct integers. Write a script to
find all pairs of elements with minimum absolute difference
(MAD) of any two elements.

Example 1
Input: @ints = (4, 1, 2, 3)
Output: [1,2], [2,3], [3,4]

Example 2
Input: @ints = (1, 3, 7, 11, 15)
Output: [1,3]

Example 3
Input: @ints = (1, 5, 3, 8)
Output: [1,3], [3,5]

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
I solve this by riffleing through the arrays twice: the first time to find the MAD, and the second time to
find all pairs separated by the MAD.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of unique integers, in proper Perl syntax, like so:

./ch-2.pl '([5,8,13,-42,-6],[-137,4,18,44,66])'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.40;
   use builtin 'inf';
   no warnings 'experimental::builtin';
   use utf8::all;


   # Is a given scalar a reference to an array of unique integers?
   sub is_array_of_unique_ints ($aref) {
      return 0 if 'ARRAY' ne ref $aref;
      for (@$aref) {return 0 if $_ !~ m/^-[1-9]\d*$|^0$|^[1-9]\d*$/}
      for    ( my $i =    0   ; $i <= $#$aref-1 ; ++$i ) {
         for ( my $j = $i + 1 ; $j <= $#$aref-0 ; ++$j ) {
            return 0 if $$aref[$i] == $$aref[$j]}}
      return 1}

   # Return all pairs of integers from given array for which
   # the absolute value of their difference is minimum:
   sub MAD ($aref) {
      my @srt = sort {$a<=>$b} @$aref;
      my $min = inf;
      my @MAD = ();
      # First pass: determine $min:
      for    ( my $i =    0   ; $i <= $#srt-1 ; ++$i ) {
         for ( my $j = $i + 1 ; $j <= $#srt-0 ; ++$j ) {
            my $adiff = abs($srt[$i]-$srt[$j]);
            if ( $adiff < $min ) {
               $min = $adiff}}}
      # Second pass: determine @MAD:
      for    ( my $i =    0   ; $i <= $#srt-1 ; ++$i ) {
         for ( my $j = $i + 1 ; $j <= $#srt-0 ; ++$j ) {
            my $adiff = abs($srt[$i]-$srt[$j]);
            if ( $adiff == $min ) {
               push @MAD, [$srt[$i], $srt[$j]]}}}
      return @MAD}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) : (     [4, 1, 2, 3],       [1, 3, 7, 11, 15],   [1, 5, 3, 8]   );
#                  Expected outputs :   ([1,2], [2,3], [3,4]),       ([1,3]),       ([1,3], [3,5])

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   say "Array = (@$aref)";
   if (!is_array_of_unique_ints($aref)) {
      say "Error: Not an array of unique integers.";
      next;
   }
   my @MAD = MAD($aref);
   my @MAD_strs = map { '[' . $_->[0] . ', ' . $_->[1] . ']' } @MAD;
   say "Pairs with minimum absolute difference = (@MAD_strs)";
}
