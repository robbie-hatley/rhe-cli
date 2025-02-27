#!/usr/bin/env -S perl -CSDA
# 麦藁.pl
use v5.32;
use utf8;

open(雪, "<:utf8", "/d/Captain’s-Den/Varna/Quenta/Tidbits.txt")
   or die "Can't open file for input. $!\n";
my @lines = <雪>;
close 雪;

open(雪2, ">:utf8", "/d/Captain’s-Den/Varna/Quenta/Tidbits_2.txt")
   or die "Can't open file for output. $!\n";
print (雪2 $_) for @lines;
close 雪2;
