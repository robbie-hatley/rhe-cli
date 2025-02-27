#!/usr/bin/perl

# echolalia.pl

use v5.32;
use strict;
use warnings;

my $line;
do {
   chomp $line = <STDIN>;
   say $line;
} until $line eq "q";

exit 0;
