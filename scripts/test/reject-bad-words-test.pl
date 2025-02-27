#!/usr/bin/perl

use v5.32;
use strict;
use warnings;

$/ = qq(\n********************\n);

my @BadWords = qw ( asdf qwer yuio );

RECORD: while (<>) {
   foreach my $BadWord (@BadWords) {
      next RECORD if ($_ =~ m/$BadWord/)
   }
   say;
}
