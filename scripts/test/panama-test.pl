#!/usr/bin/perl
# Print all lines of input if "panama" occurs in any line:
use v5.20;
my $regexp = qr(Panama);
my $bigstring = join '', <>;
print($bigstring) if $bigstring =~ /$regexp/;
