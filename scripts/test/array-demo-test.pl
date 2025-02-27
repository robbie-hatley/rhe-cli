#!/usr/bin/perl
# array-demo.pl
use strict;
use warnings;
use v5.32;

my @my_array = ();

for (@ARGV) # sets $_ to each element of @ARGV in-turn
{
   push @my_array, $_;
}

say 'You typed ', scalar(@my_array), ' arguments:';
say for @my_array;
