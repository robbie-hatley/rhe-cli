#!/usr/bin/env perl
use v5.36;
my $om = [[2,0,8],[3,4,6]];
sub double_matrix_in_situ ($mref) {
   for my $row ( 0 .. $#$mref ) {
      for my $col ( 0 .. $#{${$mref}[$row]} ) {
         $mref->[$row]->[$col] *= 2}}}
double_matrix_in_situ($om);
$"=', ';
for my $row ( 0 .. $#$om ) {
   say "[@{$om->[$row]}]";
}
