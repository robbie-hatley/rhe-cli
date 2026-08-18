#!/usr/bin/env perl
##############################################################################################################
# oitar.pl
# Given two positive integers x and y, print the corresponding rational number x/y in "37.836(5472)" format.
# Written by Robbie Hatley.
# Edit history:
# Sun Aug 16, 2026: Wrote it.
##############################################################################################################

# Pragmas and modules:
use v5.36;                       # For the "signatures" feature.
use utf8::all;                   # Use the UTF-8 transformation of Unicode for all text.
use Math::BigInt 'lib' => 'GMP'; # For unlimited-precision high-speed rational numbers.
use bigint;                      # For automatic Math::BigInt object generation.

die if 2 != scalar(@ARGV);

my $x = 0 + $ARGV[0];
my $y = 0 + $ARGV[1];

my $int = $x / $y;
my $rem = $x % $y;
my $frac = '';
my %seen;

while ($rem != 0 && !exists $seen{"$rem"}) {
   $seen{"$rem"} = length $frac;
   $rem *= 10;
   my $digit = $rem / $y;
   $frac .= "$digit";
   $rem %= $y;
}

my ($nonrep, $rep);

if (0 == $rem) {
   # Division terminated, so everything after the decimal point
   # is non-repeating.
   $nonrep = $frac;
   $rep    = '';
}
else {
   # This remainder has occurred before. Its original position
   # is the beginning of the repetition group.
   my $p = $seen{"$rem"};
   $nonrep = substr $frac, 0, $p;
   $rep    = substr $frac, $p;
}

say "$int.$nonrep($rep)";
