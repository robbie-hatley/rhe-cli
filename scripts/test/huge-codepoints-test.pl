#!/usr/bin/perl
#  /rhe/scripts/test/huge-codepoints-test.pl
use v5.32;
use strict;
use warnings;
use bigint;
my $huge_numb = (int rand 2**32) * 2**32 + int rand 2**32;
my $huge_char = eval('"\x{' . sprintf("%X", $huge_numb) . '}"');
printf("ordinal of \$huge_char = %X\n", ord $huge_char);

=pod

my $chr1 = "\x{FFFFFFFFFFFFFFFF}";
my $chr2 = "\x{9A7B3CDA578F9E27}";

say "Length  of \$chr1 = ", length($chr1);
say "Ordinal of \$chr1 = ", ord(   $chr1);

say "Length  of \$chr2 = ", length($chr2);
printf("Ordinal of \$chr2 = %X\n", ord(   $chr2));

my $max = 2**64 - 1;
printf("\$max =    %21llu\n", $max);
my $random = rand_int(0,$max);
printf("\$random = %21llu\n", $random);
my $hex3 = sprintf("%X",$random);
printf("\$hex3 =   %s\n", $hex3);
my $cmd3 = '"\x{' . $hex3 . '}"';
printf("\$cmd3 = %s\n", $cmd3);
my $chr3 = eval($cmd3);
printf("ord \$chr3 = %X\n", ord $chr3);

=cut
