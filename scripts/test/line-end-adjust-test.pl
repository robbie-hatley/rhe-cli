#!/usr/bin/perl
#  /rhe/scripts/test/line-end-adjust-test.pl
use v5.32;
use strict;
use warnings;
my $var  = "111111111111111\x0d";
   $var .= "222222222222222\x0a";
   $var .= "333333333333333\x0a\x0a";
   $var .= "444444444444444\x0d\x0d";
   $var .= "555555555555555\x0d\x0a";
   $var .= "666666666666666\x0a\x0d";
   $var .= "777777777777777\x0d\x0d\x0a\x0a";
   $var .= "888888888888888\x0d\x0a\x0a\x0d";
$var =~ s/(?:\x0d|\x0a)+/\x0d/g;
print $var;
