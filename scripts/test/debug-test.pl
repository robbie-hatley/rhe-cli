#!/usr/bin/perl
# debug-test.pl
use v5.32;
use strict;
use warnings;
my $db = 1; # set debug-control variable
say (scalar(@ARGV)) if $db;
if (scalar(@ARGV) < 2) {die 'Need 2 arguments.';}
my $Bob = shift;
say "\$Bob = $Bob" if $db;
my $Sue = shift;
say "\$Sue = $Sue" if $db;
my $Tom = 7.68*$Bob - 3.27*$Sue;
say "\$Tom = $Tom";
exit;
