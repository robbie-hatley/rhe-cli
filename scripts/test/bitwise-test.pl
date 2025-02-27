#!/usr/bin/perl

use v5.32;
use strict;
use warnings;

my $a = 0b0010_1010;
my $b = 0b1011_1101;

my $and =           $a & $b;
my $nan = 0xFF & (~($a & $b));
my $orr =           $a | $b;
my $nor = 0xFF & (~($a | $b));
my $xor =           $a ^ $b;
my $xnr = 0xFF & (~($a ^ $b));

printf("\$a   = %08b\n", $a);
printf("\$b   = %08b\n", $b);
printf("\$and = %08b\n", $and);
printf("\$nan = %08b\n", $nan);
printf("\$orr = %08b\n", $orr);
printf("\$nor = %08b\n", $nor);
printf("\$xor = %08b\n", $xor);
printf("\$xnr = %08b\n", $xnr);

exit(0);
