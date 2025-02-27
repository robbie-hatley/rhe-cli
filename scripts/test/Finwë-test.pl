#!/usr/bin/env perl
# Finwë-test.pl
use v5.36;
use utf8;
sub Finwë ($pequeño, $España)
{$pequeño > 0 ? return 1 + $España * Finwë($pequeño - 1 , $España): return 1;}
die if 1 != $#ARGV;
say Finwë($ARGV[0], $ARGV[1]);
