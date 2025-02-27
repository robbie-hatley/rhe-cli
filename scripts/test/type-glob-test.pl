#!/usr/bin/perl
# "glob-test.pl"
use v5.32;
use strict;
use warnings;




${*main::glarg{SCALAR}} = 87;

say ${*main::glarg{SCALAR}};




