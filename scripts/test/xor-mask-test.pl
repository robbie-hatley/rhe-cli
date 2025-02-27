#!/usr/bin/perl
# /rhe/scripts/test/xor-mask-test.pl
use v5.32;

my $base = 37;
my $offset = 45; # 0b00101101

my $lower = $base + 6;
my $upper = $base + 6 + $offset;

my $lcmask = $lower ^ $lower;
my $ucmask = $upper ^ $lower;

say(($base + 5) ^ $lcmask);
say(($base + 6) ^ $lcmask);
say(($base + 7) ^ $lcmask);
say(($base + 5) ^ $ucmask);
say(($base + 6) ^ $ucmask);
say(($base + 7) ^ $ucmask);

