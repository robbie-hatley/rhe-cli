#!/usr/bin/env -S perl -CSDA

use v5.32;
use strict;
use warnings;
use utf8;

BEGIN {say "AAARRRFFF!!!!!!!";}

while (<>)
{
   say "Arf\N{U+00A0}arf!";
}

END {say "Arf arf arf arf arf arf arf!!!";}
