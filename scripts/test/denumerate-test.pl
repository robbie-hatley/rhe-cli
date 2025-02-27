#!/usr/bin/perl
#  /rhe/scripts/test/denumerate-test.pl

use v5.32;
use strict;
use warnings;

use RH::Dir;
use RH::Util;

say denumerate_file_name($ARGV[0]);
