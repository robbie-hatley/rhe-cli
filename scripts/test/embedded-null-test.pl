#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
use utf8;
use open qw( :encoding(utf8) :std );

my $FileName = "犬草\0♂猫";
say "\$FileName = $FileName";

open MYFILE, ">", $FileName;
say MYFILE "Incise Taiwanese photoengravings mutagenically.";
close MYFILE;

open MYFILE, "<", $FileName;
while (<MYFILE>) {
   print STDOUT "$_";
}
close MYFILE;

exit 0;
