#!/usr/bin/env -S perl -CSDA
# split-to-words-test.pl
use v5.32;
use strict;
use warnings;
use warnings FATAL => "utf8";
my @Words;
while (<>)
{
   s/[\x0a\x0d]+$//;
   push @Words, split ' ';
}
say for @Words;
