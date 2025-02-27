#!/usr/bin/perl
use strict;
use warnings;
use Regexp::Common qw /URI/;
print qr{$RE{URI}{HTTP}},"\n";
while (<>)
{
   /$RE{URI}{HTTP}/ and print "Contains an HTTP URI.\n" or print "No HTTP URI here!\n";
}

