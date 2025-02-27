#!/usr/bin/perl
# deg2rad-old-test.pl
use v5.32;
use Math::Trig;
sub DegToRad
{
   my $deg = shift @_ ;
   return pi * $deg / 180;
}
exit if 1 != @ARGV;
say DegToRad($ARGV[0]);
