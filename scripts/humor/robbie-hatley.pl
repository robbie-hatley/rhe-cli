#!/usr/bin/env perl
use bigint;
my $n=9617996763795502534212842581842;
my $m=-8;$_=$n&(0xff)<<$m,$_>>=$m,
print chr while(($m+=8)<=96);print "\n";
