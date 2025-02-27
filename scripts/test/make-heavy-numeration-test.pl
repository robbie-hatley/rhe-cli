#!/usr/bin/perl
# make-heavy-numeration-test.pl
use v5.32;
use strict;
use warnings;
chdir '/cygdrive/d/test-range/heavy-numeration-test';
for (9950..9989)
{
   my $number = sprintf '%04d', $_ ;
   my $newname = 'test-(' . $number . ').txt';
   system("cp --preserve=timestamps 'test.txt' '$newname'");
}
