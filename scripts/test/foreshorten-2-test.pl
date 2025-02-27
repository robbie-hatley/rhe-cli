#!/usr/bin/perl
#  /rhe/scripts/test/foreshorten-test-2.pl
#  Tests

use strict;
use warnings;
use feature qw(say);

our @array = (1..100);  # @array contains integers 1 through 100
say join ' ', @array;   # prints 1 through 100

say '';

$#array = 12; # @array now contains integers 1 through 13 (indices 0..12)
say join ' ', @array;   # prints 1 through 13

say '';

$#array = -1; # @array is now empty, with no valid indices or contents.
say join ' ', @array;   # prints blank line
