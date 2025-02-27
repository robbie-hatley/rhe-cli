#!/usr/bin/perl
use strict;
use warnings;
use v5.32;
our $string = "Fred:Ethel:Lucy:Ricky";
our @array  = split ':', $string;
say "Number of fields = ", scalar(@array);
say $array[$_] foreach (0..$#array);
