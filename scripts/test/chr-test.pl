#!/usr/bin/perl

use v5.32;
use strict;
use warnings;

my @msg = (78,111,119,32,104,105,114,105,110,103,46,10,0);

foreach (@msg) {
   print(chr($_));
}
