#!/usr/bin/env perl
#  prepend-to-array-ref-test.pl
use v5.36;
my @a = ([1,3,5],[36,84],[0,-2]);
unshift @$_, 17 for @a;
$,=', '; say @$_ for @a;
