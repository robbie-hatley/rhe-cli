#!/usr/bin/env -S perl -CSDA
# middle-character-test-perl.pl
use v5.32;
use strict;
use warnings;
use warnings FATAL => "utf8";
exit(1) unless scalar(@ARGV) == 1;
my $StringSize = length($ARGV[0]);
exit(1) unless $StringSize%2 == 1;
say substr($ARGV[0], ($StringSize-1)/2, 1);
exit(0);
