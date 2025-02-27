#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
my $binary = '0b' . '1' x 25 . '0' x 7; # binary representation
my $value  = eval $binary;              # numerical value
printf("Binary:      %b\n", $value);
printf("Hexidecimal: %x\n", $value);
printf("Decimal:     %d\n", $value);
