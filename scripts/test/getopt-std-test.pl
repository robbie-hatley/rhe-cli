#!/usr/bin/env -S perl -C63
use v5.36;
use utf8;
use Getopt::Std;
our ($opt_a, $opt_b, $opt_c);
getopts("a:bc");
say 'a = ', $opt_a // 'null';
say 'b = ', $opt_b // 'null';
say 'c = ', $opt_c // 'null';
