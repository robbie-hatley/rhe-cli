#!/usr/bin/perl
#temp-file-test.p
use strict;
use warnings;
open  TEMP, '>', 'C:/Temp/asdf.tmp';
print TEMP "asdf\n";
close TEMP;
