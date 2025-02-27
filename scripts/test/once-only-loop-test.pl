#!/usr/bin/perl
# "once-only-loop-test.pl"
use v5.32;
use strict;
use warnings;

for (5)
{
   printf("\$_ = %d\n", $_);
}
