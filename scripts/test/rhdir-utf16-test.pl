#!/usr/bin/perl
use v5.32;
use strict;
use warnings;

use Encode;
use open qw( :encoding(UTF-16) :std );

my @files = map {decode('UTF-16', $_);} <*>;
say for @files;
