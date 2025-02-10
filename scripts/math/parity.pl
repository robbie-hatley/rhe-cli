#!/usr/bin/env perl
# parity.pl
use v5.16;
my $odds = 0;
my $evns = 0;
for (@ARGV) {
   if ($_ % 2) {
   	   ++$odds;
   	   say "$_ is odd"
   }
   else {
      ++$evns;
      say "$_ is even"
   }
}
say '';
say 'Summary:';
say "$odds odds";
say "$evns evens";
