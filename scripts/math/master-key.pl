#!/usr/bin/perl
use strict;
use warnings;

my $mask = shift or die "Usage: \"master-key.pl <bitmask>\"\n";
die "Invalid mask: only 0s and 1s allowed.\n" unless $mask =~ /^[01]+$/;

my @bits = split //, $mask;
my @positions = grep { $bits[$_] eq '1' } (0 .. $#bits);
my $subset_count = 2 ** @positions;

for my $num (0 .. $subset_count - 1) {
    my @binary = ('0') x @bits;
    for my $i (0 .. $#positions) {
        $binary[$positions[$i]] = (($num >> $i) & 1) ? '1' : '0';
    }
    print join('', @binary), "\n";
}
