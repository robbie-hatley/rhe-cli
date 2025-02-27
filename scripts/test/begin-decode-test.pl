#!/usr/bin/perl -CSD
#  begin-decode-test.pl
use v5.32;
use RH::Dir;
BEGIN {$_ = RH::Dir::decode_utf8 $_ for @ARGV;}
say for @ARGV;
