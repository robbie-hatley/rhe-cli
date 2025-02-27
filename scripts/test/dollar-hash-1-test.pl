#!/usr/bin/perl
use strict;
use warnings;
use v5.32;

for ( my $i = 0 ; $i < $#ARGV ; $i++ ) {
   say "$ARGV[$i]";
}
