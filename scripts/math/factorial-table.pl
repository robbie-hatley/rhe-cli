#!/usr/bin/env perl
# "factorial-table.pl"
use v5.32;
use Math::BigInt;
scalar(@ARGV) >= 1 && $ARGV[0] =~ m/^\d+$/
or die "Error: this program requires one argument, which must be a non-negative\n".
       "integer. This program will print the factorials of all integers from 1\n".
       "through that number.\n";
my $n = $ARGV[0];
my $x = Math::BigInt->new(1);
printf("%3d! = %165s\n", $_, $x *= $_) for 1 .. $n;
