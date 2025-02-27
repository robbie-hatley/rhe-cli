#!/usr/bin/perl
#  /rhe/scripts/test/sort-test.pl
use v5.32;
use strict;
use warnings;
no  warnings 'experimental::smartmatch';
our @Dogs = qw( Fido Rover Bonzo Cujo Chompjaw Zulu );
$,=' ';
say sort @Dogs;
our @Numbers = (83, 57, 684, 9482, 34827, 5, 99846, 23);
say sort {$a cmp $b} @Numbers;
say sort {$a <=> $b} @Numbers;

