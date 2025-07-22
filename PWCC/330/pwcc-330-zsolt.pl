#!/usr/bin/perl -w
use strict;
use warnings;
my $INPUT_STRING = "7ab1900asdka0591jdapow366rei4w00etlskdjf910850ewruisqe00q34596710303ero0000091058506907s3";
my @CORRECT_OUTPUT = (7, 1900, 591, 366, 4, 0, 910850, 0, 34596710303, 91058506907, 3);
my @OUTPUT = map(int($_), split(/\D+/, $INPUT_STRING));
# OR TO BE COMPATIBLE WITH BIG INTEGERS:
# my @OUTPUT = map($_ =~ m/^0+(\d+)/ ? $1 : $_, split(/\D+/, $INPUT_STRING));
print 'CORRECT..... ', join(" ", @CORRECT_OUTPUT), "\n\n";
print 'RESULT...... ', join(" ", @OUTPUT), "\n\n";
print($_ eq shift(@OUTPUT) ? 'OK ' : 'FAIL ') foreach (@CORRECT_OUTPUT);
print "\n\n";
