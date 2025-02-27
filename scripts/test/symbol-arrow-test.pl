#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
no strict "refs";

our $sprat = 42;

say $main::sprat;
say *main::sprat;
say *main::sprat{SCALAR};
say ${*main::sprat{SCALAR}};
