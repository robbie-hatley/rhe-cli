#!/usr/bin/perl
use v5.32;
use strict;
use warnings;

while (<>) {
   say /Frodo|Pippin|Merry|Sam/i ? "Yes." : "No." ;
}
