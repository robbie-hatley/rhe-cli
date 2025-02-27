#!/usr/bin/perl
use v5.36;
open FRED, $ARGV[0] or die "Return to sender;\naddressee unknown.\nNo such person\nat this home.\n";
binmode STDIN  , ":encoding(UTF-8)";
binmode STDOUT , ":encoding(UTF-8)";
binmode STDERR , ":encoding(UTF-8)";
binmode FRED   , ":encoding(UTF-8)";
while (<FRED>) {chomp;$ARGV[1]<length($_) and say substr $_, $ARGV[1], 1 or say 'past end'}
close FRED
