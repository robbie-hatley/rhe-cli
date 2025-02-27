#!/usr/bin/perl
#  /rhe/scripts/test/t-test-1.pl
use v5.32;
use strict;
use warnings;
use Cwd;
use RH::Util;
use RH::Dir;
say "Does stdin exist? ", (-e "./stdin") ? "yes" : "no";
say "Is stdin opened to tty? ", (-t "./stdin") ? "yes" : "no";
