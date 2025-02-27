#!/usr/bin/perl
# "zeros-ones-V3.pl"
use v5.32;
use strict;
use warnings;
our $string = $ARGV[0];
our $m0 = 0;
our $m1 = 0;
our $mo = 0;
length() > $m0 and $m0 = length() for $string =~ /0+/g;
length() > $m1 and $m1 = length() for $string =~ /1+/g;
length() > $mo and $mo = length() for $string =~ /[^01]+/g;
say "Max zeros count = ", $m0;
say "Max ones  count = ", $m1;
say "Max other count = ", $mo;
