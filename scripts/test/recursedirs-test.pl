#!/usr/bin/perl
#  /rhe/scripts/test/recursedirs-test.pl
use v5.32;
use strict;
use warnings;
use Cwd;

use RH::Dir;

sub f {
   my $dir = getcwd();
   say $dir;
}

RecurseDirs(\&f);
