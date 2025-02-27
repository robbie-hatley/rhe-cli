#!/usr/bin/perl

################################################
# /rhe/scripts/test/winchomp-bom-test.pl
################################################

use v5.32;
use strict;
use warnings;
if ($] >= 5.018) {no warnings 'experimental::smartmatch';}
use charnames ':full';
use open qw( :encoding(utf8) :std );
use warnings FATAL => "utf8";
use utf8;

use RH::WinChomp;

our $text = "This is\nsome text\nwith embedded\nnewline characters.\n";

print "Original text:\n";
print $text;
print "WinChomped text:\n";
print winchomp $text;
