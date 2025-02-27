#!/usr/bin/perl
# "zeros-ones-V2.pl"
use feature 'say';
use strict;
use warnings;
our $string = $ARGV[0];
our @zeros  = split /[^0]+/ , $string , -1;
our @ones   = split /[^1]+/ , $string , -1;
our @others = split /[01]+/ , $string , -1;
say "Max zeros  count = ", (sort {$b<=>$a} map {length} @zeros )[0];
say "Max ones   count = ", (sort {$b<=>$a} map {length} @ones  )[0];
say "Max others count = ", (sort {$b<=>$a} map {length} @others)[0];
