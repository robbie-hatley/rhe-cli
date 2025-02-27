#!/usr/bin/perl
#  /rhe/scripts/test/unicode-collate-array-of-hashes-test.pl

use v5.32;
use strict;
use warnings;
use open qw( :utf8 :std );
use warnings FATAL => "utf8";
use Unicode::Collate;
use RH::Dir;

my $files = GetFiles;
my $sorter = Unicode::Collate->new();
my @sorted = sort {$sorter->cmp($a->{Name},$b->{Name});  } (@{$files});
foreach my $file (@sorted) {
   say $file->{Name};
}
