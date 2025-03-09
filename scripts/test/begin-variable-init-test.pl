#!/usr/bin/perl
# begin-variable-init-test.pl
use strict;
use warnings;
our $x = 5;
my  $y = 6;
BEGIN {
   print "\$x = $x\n";
   print "\$y = $y\n";
}
