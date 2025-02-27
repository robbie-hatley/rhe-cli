#!/usr/bin/perl
use v5.32;
use strict;
use warnings;

use Encode;
use open qw( :encoding(utf8)   :std );

my @files = map {decode('utf8',   $_);} <*>;
say for @files;
