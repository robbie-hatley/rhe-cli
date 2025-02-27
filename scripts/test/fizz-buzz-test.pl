#!/usr/bin/env -S perl -CSDA

# fizz-buzz-test.pl

use v5.32;
use strict;
use warnings;
use experimental 'switch';
use utf8;
use warnings FATAL => "utf8";

1 == scalar(@ARGV) && $ARGV[0] =~ m/^\d+$/ && '0' ne substr($ARGV[0],0,1) && $ARGV[0] >= 1
or die "Error: fizz-buzz-test.pl takes exactly one argument, which must be a positive integer.\n";
printf("%s\n", 'Fizz' x (0 == $ARGV[0] % 3) . 'Buzz' x (0 == $ARGV[0] % 5));
