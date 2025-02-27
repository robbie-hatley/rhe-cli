#!/usr/bin/perl

use v5.32;
use strict;
use warnings;

my $ref  = "";
my $blat = "";
my $word = "";

$ref = \\\\\$::argle; # using argle before assigning to it; will it be undefined?
$blat = $$$$$$ref;
$word = (defined($blat)) ? "definded, and its value is $blat" : 'undefined' ;
print("blat is $word.\n");

$::argle = 7;
$ref = \\\\\$::argle;
$blat = $$$$$$ref;
$word = (defined($blat)) ? "definded, and its value is $blat" : 'undefined' ;
print("blat is $word.\n");

undef $::argle;
$ref = \\\\\$::argle;
$blat = $$$$$$ref;
$word = (defined($blat)) ? "definded, and its value is $blat" : 'undefined' ;
print("blat is $word.\n");
