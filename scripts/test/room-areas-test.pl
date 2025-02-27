#!/usr/bin/perl
# room-areas-test.pl
while (<>)
{
   chomp;
   my ($width,$depth) = split ',', $_;
   print $width * $depth, "\n";
}
