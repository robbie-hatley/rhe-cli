#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
use utf8;
use open qw( :encoding(utf8) :std );
no warnings "deprecated";
$[ = 42;
say "\$[ = ",                $[               ;
say "scalar(\@ARGV) = ",     scalar(@ARGV)    ;
say "\$#ARGV - \$[ + 1 = ",  $#ARGV - $[ + 1  ;
#४५६७
our $string = v1.20.300.4000;
say "Length of \$String = ",  length($string);
say "\$String = $string";
