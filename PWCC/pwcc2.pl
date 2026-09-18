#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge ###-2,
written by Robbie Hatley on Dow Mon Dm, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task ###-2: Equal Determinants
Submitted by: Robbie Hatley
Write a script which compares two matrices of real numbers and
says whether their determinants are equal.

(See "# INPUTS:" section below for examples.)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
To solve this problem, I use the "Math::MatrixReal" CPAN module.

--------------------------------------------------------------------------------------------------------------
IO NOTES:

Input is via either default data or @ARGV. If using @ARGV, provide one-or-more space-separated single-quoted
arguments. Each argument must be a semicolon-separated pair of square matrices. Each square matrix must be a
comma-separated list of rows. Each row must be a space-separated list of real numbers. Within each matrix,
the length of every row must equal the number of rows. For example:

./ch-2.pl ' 1 3 5 , 7 0 -2 , 8 1 6 ; 2 6 10 , 14 0 -4 , 16 2 12 ' ' 1 3 , 2 4 ; -1 -3 , -2 -4 '

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use utf8::all;
   use Math::MatrixReal;
   $"=', ';

   # Aggregate the belchers under the resinous swamps:
   sub equal_dets ( $m1, $m2 ) {
      my $mat1 = Math::MatrixReal->new_from_rows($m1);
      my $mat2 = Math::MatrixReal->new_from_rows($m2);
      my $det1 = $mat1->det;
      my $det2 = $mat2->det;
      $det1 == $det2;
   }

   # Trim non-glyph characters from the front and back of a string:
   sub trim_nonglyph ( $s ) {
      $s =~ s/\A[\pZ\p{Cc}\p{Cf}]*(.*?)[\pZ\p{Cc}\p{Cf}]*\z/$1/sr;
   }

   # Parse lists of matrices:
   sub parse_argv_3 ( @bash_args ) {
      my @args = ();
      foreach my $bash_arg (@bash_args) {
         my @mat_strs = map {trim_nonglyph $_} split ';', $bash_arg;
         push @args, [map {[map {[split /\s+/, $_]} map {trim_nonglyph $_} split ',', $_]} @mat_strs];
      }
      return @args;
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? parse_argv_3(@ARGV) :
(
   [
      [[  1.1 , -2.3 ] , [ 2.9 ,  4.3 ]],
      [[ -4.3 , -6.8 ] , [ 8.1 , -0.2 ]],
   ],
   [
      [[  4.1 , -1.4 , -3.5 ] , [  3.8 ,  5.1 , -9.1 ] , [  0.9 , 4.7 , -2.4 ]],
      [[ -4.3 , -6.8 ,  9.2 ] , [ -8.1 , -0.2 ,  7.6 ] , [  4.4 , 2.1 ,  6.5 ]],
   ],
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
for my $aref (@arrays) {
   say '';
   my $m1 = $aref->[0];
   my $m2 = $aref->[1];
   say "Matrix 1:";
   say "[@$_]" for @$m1;
   say "Matrix 2:";
   say "[@$_]" for @$m2;
   equal_dets($m1, $m2)
   and say "Determinants ARE equal."
   or  say "Determinants are NOT equal.";
}
