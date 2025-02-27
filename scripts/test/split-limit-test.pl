#!/usr/bin/perl
use strict;
use warnings;
use v5.32;

our $string = "once upon a time, three pigs jiggled, wriggled, giggled";
our @array  = split ', ', $string, 3;

say "Number of fields = ", scalar(@array);

foreach (0..$#array) {
   say $array[$_];
}
