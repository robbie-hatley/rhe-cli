#!/usr/bin/perl
#  /rhe/scripts/test/test-clock.pl
use v5.32;
use strict;
use warnings;
use RH::Util;

print `clock.pl UTC     24H  short`;
print `clock.pl UTC     AMPM short`;
print `clock.pl Pacific 24H  short`;
print `clock.pl Pacific AMPM short`;
print `clock.pl UTC     24H  long`;
print `clock.pl UTC     AMPM long`;
print `clock.pl Pacific 24H  long`;
print `clock.pl Pacific AMPM long`;
