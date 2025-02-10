#!/usr/bin/env perl
# "max.pl"
# Prints maximum of numbers given as CL args.
use v5.32;
use List::Util qw( max );
say max @ARGV;
