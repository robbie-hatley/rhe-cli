#!/usr/bin/env perl
# "semirandom-upward-arpeggio.pl"

use v5.16;

our $range = (defined $ARGV[0]) ? $ARGV[0] : 10;
our @array = (1..$range);

for my $i (0..$#array) {
   my $span = rand(4)+1;
   $array[$i] += (rand(2*$span) - $span);
   say $array[$i];
}
