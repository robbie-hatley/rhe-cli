#!/usr/bin/perl
use v5.32;
use strict;
use warnings;

$::argle = 'Fred';

sub PrintArg
{
   say $::argle;
}

foreach (@ARGV)
{
   local $::argle = $_;
   PrintArg;
}

say $::argle;
