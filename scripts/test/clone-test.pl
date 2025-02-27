#!/usr/bin/perl
# clone-test.pl
use v5.36;
use strict;
use warnings;
use Clone 'clone';
my $matrix = [ [1,2,3],[4,5,6],[7,8,9] ];
say "original matrix:";
say "@$_" for @$matrix;
my $copy = clone($matrix);
say "copy of matrix:";
say "@$_" for @$copy;
$copy->[1]->[1] = 0;
say "altered copy:";
say "@$_" for @$copy;
say "original matrix remains unaltered:";
say "@$_" for @$matrix;
