#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
use utf8;
use open qw( :encoding(utf8) :std );
use charnames qw(:full);

my $FileName = "\x01犬草\x02\n\N{MALE SIGN}猫\x03\e\a\x04";

open MYFILE, ">", $FileName;
print MYFILE "Oh, my.\n";
close MYFILE;

open MYFILE, "<", $FileName;
while (<MYFILE>) {
   print "$_";
}
close MYFILE;

exit 0;
