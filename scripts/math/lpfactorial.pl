#!/usr/bin/env perl
# "lpfactorial.pl"
use v5.32;
use Math::BigInt;
scalar(@ARGV) >= 1 && $ARGV[0] =~ m/^\d+$/
or die "Error: This program requires one argument, which must be a non-negative integer.\n"
     . "This program will then print the factorial of that number in low precision.\n";
my $x = $ARGV[0];
my $f = Math::BigInt->bfac($x);
$f->bround(5);
my $s = $f->bsstr();
say "$x! = $s";
exit 0;
