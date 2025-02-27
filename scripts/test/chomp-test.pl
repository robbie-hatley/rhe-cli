#!/usr/bin/perl

# Address of this file: "/rhe/scripts/test/chomp-test.pl"

# Description: Tests whether "chomp" removes both \x0d AND \x0a from
# the ends of text strings from Windows text files.

#  (Note, 2014-03-17: Results: "chomp" removes only the "\x0a",
#  not the "\x0d".)

use v5.32;
use strict;
use warnings;

while (<>) {
   chomp;
   print;
}
