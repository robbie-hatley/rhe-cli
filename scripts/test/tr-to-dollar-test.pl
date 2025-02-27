#!/usr/bin/perl

use v5.32;
use strict;
use warnings;

while (<>) {
   tr/A-Za-z0-9/$/;
   print;
}
