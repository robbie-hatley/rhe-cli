#!/usr/bin/perl
#  /rhe/scripts/test/t-test-2.pl
use v5.32;
use strict;
use warnings;
use Cwd;
use RH::Util;
use RH::Dir;
print `perl -E 'say "Does stdin exist? ", (-e "./stdin") ? "yes" : "no";'`;
print `perl -E 'say "Is stdin opened to tty? ", (-t "./stdin") ? "yes" : "no";'`;
