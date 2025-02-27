#!/usr/bin/perl
#  /rhe/scripts/test/winchomp-test.pl
#  Tests my "winchomp" function, which removes first \x0a, then \x0d,
#  from the end of a line of text.

use v5.32;
use strict;
use warnings;
use RH::WinChomp;

while (<>) {
   winchomp;
   say;
}
