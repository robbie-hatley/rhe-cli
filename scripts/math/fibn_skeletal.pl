#!/usr/bin/env perl
use v5.16;
my $n = $ARGV[0];
say((((1+sqrt(5))/2)**($n+1)-((1-sqrt(5))/2)**($n+1))/sqrt(5));
