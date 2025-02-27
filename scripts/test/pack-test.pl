#!/usr/bin/perl

use v5.32;
use strict;
use warnings;

my %stuff = (
   NAME => "Robbie Hatley",
   RANK => "Captain",
   IDNO => "80537426",
);

while ( (my $key, my $val) = each (%stuff) ) {
   say("Key = $key      Val = $val");
}

my $packed = pack("A3",%stuff);
say $packed;
