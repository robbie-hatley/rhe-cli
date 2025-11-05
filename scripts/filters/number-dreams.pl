#!/usr/bin/env perl
use strict;
use warnings;
binmode STDIN , ":utf8" or die "Couldn't binmode STDIN  to \":utf8\".\n$!\n";
binmode STDOUT, ":utf8" or die "Couldn't binmode STDOUT to \":utf8\".\n$!\n";
use warnings FATAL => "utf8";
my $n = 1;
while (<>) {
   print;
   s/^\N{BOM}//;
   chomp;
   if (m/^~{49}$/) {
      print "Dream #", $n++, "\n";
   }
}
