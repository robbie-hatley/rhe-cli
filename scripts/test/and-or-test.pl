#!/usr/bin/env -S perl -CSDA

use v5.32;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;

sub f($);
sub g($);

# main()
{
   my $x = $ARGV[0];
   my $y = 0.0;
   my $condition = $ARGV[1];
   $condition and ($y=f($x)) or ($y=g($x)); # fails if f($x) is 0 !!!!
   say $y;
   exit(0);
}

sub f($)
{
   my $x = shift;
   return 3.1*$x+6.2;
}

sub g($)
{
   my $x = shift;
   return 2.2*$x-31.86;
}

