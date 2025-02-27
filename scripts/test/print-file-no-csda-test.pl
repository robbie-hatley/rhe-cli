#!/usr/bin/perl
# print-file-no-csda-test.pl
use v5.32;
use warnings FATAL => "utf8";
use utf8;

use RH::Dir;

die "No file specified.\n" if scalar(@ARGV) < 1;

foreach my $path (@ARGV)
{
   warn "File does not exist.\n" and next if ! -e $path;
   warn "File is not a file. \n" and next if ! -f $path;
   my $fh;
   open $fh, '<', $path
   or warn "Can't open ${path}.\n" and next;
   for my $line (<$fh>)
   {
      print $line;
   }
   close $fh;
}
