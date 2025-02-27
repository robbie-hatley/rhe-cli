#!/usr/bin/perl

use v5.32;
use strict;
use warnings;

@::sources = ("hi", "there", "TARGET23", "hello", "TARGETblarg", "world");
@::results = ();

map
{
   my $matched = ($_ =~ s/^TARGET//);
   push(@::results, $_) if $matched;
}
@::sources;

say join(", ", @::results);
