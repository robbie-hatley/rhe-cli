#!/usr/bin/env perl

# "robbie-hatley-annotated.pl"

use bigint;
# my $n = 0x79656C74614820656962626F52;
#            y e l t a H   e i b b o R
# Then convert that back to decimal:
my $n=9617996763795502534212842581842;
my $m=-8;$_=$n&(0xff)<<$m,$_>>=$m,
print chr while(($m+=8)<=96);print "\n";

