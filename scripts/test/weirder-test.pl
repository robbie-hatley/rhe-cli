#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
no strict "refs";

BEGIN {
   $::{A} = \1.23;
}

say ( A() ) ;

*{"\x{38}\x{73}\x{64}"} = \"\x{34}";
say(ord(${"\x{38}\x{73}\x{64}"}), "\n");
