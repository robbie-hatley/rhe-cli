#!/usr/bin/env perl
# "factorials.pl"
# Written by Robbie Hatley.
# Updated 2025-02-10.
use v5.16;
use Math::BigInt;
@ARGV == 2 && $ARGV[0] =~ m/^\d+$/ && $ARGV[1] =~ m/^\d+$/ && $ARGV[0] < $ARGV[1]
or die "Error: this program requires two arguments, which must be non-negative integers\n".
       "with the second greater than the first. This program will print the factorials\n".
       "of all numbers from the first argument to the second argument.\n";
my $m = Math::BigInt->new($ARGV[0]);
my $n = Math::BigInt->new($ARGV[1]);
foreach ( $m .. $n ) {
   my $x = Math::BigInt->new($_);
   my $f = $x->copy();
   $f->bfac();
   say "$x! = $f";
}
