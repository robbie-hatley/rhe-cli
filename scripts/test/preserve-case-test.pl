#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
my @lines = <>;
chomp for @lines;
s/dog/cat/g for @lines;
s/doG/caT/g for @lines;
s/dOg/cAt/g for @lines;
s/dOG/cAT/g for @lines;
s/Dog/Cat/g for @lines;
s/DoG/CaT/g for @lines;
s/DOg/CAt/g for @lines;
s/DOG/CAT/g for @lines;
say for @lines;
