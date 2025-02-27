#!/usr/bin/perl
use v5.32;
use strict;
use warnings;

open  MYFILE, ">", "dkv.txt";
print MYFILE "Red dragon sleeps in\nstoney equanimity,\ndreaming lustily.\n";
close MYFILE
