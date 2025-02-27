#!/usr/bin/perl
# look-back-test.pl
use v5.32;
my $re = qr((?<=fred)d+);
while (<>) {print if /$re/;}
