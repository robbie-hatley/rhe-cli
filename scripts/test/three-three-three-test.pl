#!/usr/bin/perl
use v5.20;
# three-three-three-test.pl
my $string = scalar @ARGV > 0 ? $ARGV[0] : "";
$string =~ s/^(...)(...)(...)$/$1-$2-$3/;
say $string;
