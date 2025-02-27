#!/usr/bin/perl

use v5.32;
use strict;
use warnings;

my $a = "3 + 5";
my $b = "8";

say $a . " is equal to " . $b . ".";        # dot operator
say $a, " is equal to ", $b, ".";           # list
say "$a is equal to $b.";                   # interpolation
say join("", $a, " is equal to ", $b, "."); # join
