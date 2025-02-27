#!/usr/bin/perl
# Operator Test

use v5.32;
use strict;
use warnings;

my $A = 123;
my $B = 456;
my $C = 3;
my $scrwid = 78;

print('$A = ', $A,"\n");
print('$B = ', $B,"\n");
print('$C = ', $C,"\n");

print('$A + $B = ', $A + $B,"\n");
print('$A . $B = ', $A . $B,"\n");
print('$A * $C = ', $A * $C,"\n");
print('$A x $C = ', $A x $C,"\n");

say "_" x $scrwid;
