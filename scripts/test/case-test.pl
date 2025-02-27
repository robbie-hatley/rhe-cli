#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
use utf8;
use open qw( :encoding(utf8) :std );
use charnames qw(:full);
my $beast = "\N{LATIN SMALL LETTER DZ}ur";
say for $beast, ucfirst($beast), uc($beast);
