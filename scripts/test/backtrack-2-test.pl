#!/usr/bin/perl
# backtrack-test-1.pl
use v5.32;
use strict;
use warnings;
if ( ("a" x 20 . "b") =~ /(a*a*a*a*a*a*a*a*a*a*a*a*)*+[^Bb]$/ )
{
   say 'Yes.';
}
else
{
   say 'No.';
}
