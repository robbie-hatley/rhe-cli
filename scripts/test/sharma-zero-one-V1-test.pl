#!/usr/bin/perl
#  /rhe/scripts/test/sharma-zero-one-V1.pl
use v5.32;
use strict;
use warnings;
my $string = $ARGV[0] // die "Insufficient args";
local $b;
my @m = (0) x 2; # holds the max counts
1 while $string =~ m{
   (?{ local $a = 1 })
   (?:(0)|(1))(?:(?(1)0|1)(?{ $a++ }))*
   (?{
      *b = \$m[$1//$2];
      ($a > $b) && ($b = $a);
   })
   (?=(?(1)1|0)|$)
}xg;
say $string;
say "max overall=", $b//0;
say "max zeros count=", $m[0];
say "max ones  count=", $m[1];
