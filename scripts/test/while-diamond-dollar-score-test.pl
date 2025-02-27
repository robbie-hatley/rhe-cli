#!/usr/bin/perl
#  /rhe/scripts/test/while-diamond-dollar-score-test.pl
use v5.32;
use strict;
use warnings;
$_ = "Himmelblau\n";
print;
{
   local $_;
   while (<>)
   {
      print;
   }
}
print;
