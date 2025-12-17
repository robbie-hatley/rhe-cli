#!/usr/bin/env perl
# harshad.pl
use v5.16;
use utf8::all;
use Math::BigInt;
use List::Util 'sum0';
my $n = Math::BigInt->new(@ARGV[0]);
my $s = Math::BigInt->new(sum0 split //, $ARGV[0]);
my $z = Math::BigInt->bzero();
if ($z->beq($n->bfmod($s))) {say 'yes'}
else                        {say 'no' }
