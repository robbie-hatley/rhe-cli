#!/usr/bin/perl

use v5.36;

# Return a ref to a deep copy of a referred-to rectangular 2-d matrix:
sub matrix_deep_copy($mref){
   # Make an array to hold our deep copy:
   my @matrix_copy;
   # Copy the elements of each row rather than ref to matrix or refs to rows:
   for my $oldrow (@$mref){
      my @newrow;
      for my $element (@$oldrow){
         push @newrow, $element;
      }
      push @matrix_copy, \@newrow;
   }
   return \@matrix_copy;
}

my $matrix = [ [1,2,3],[4,5,6],[7,8,9] ];
say "original matrix:";
say "@$_" for @$matrix;
my $copy = matrix_deep_copy($matrix);
say "copy of matrix:";
say "@$_" for @$copy;
$copy->[1]->[1] = 0;
say "altered copy:";
say "@$_" for @$copy;
say "original matrix remains unaltered:";
say "@$_" for @$matrix;
