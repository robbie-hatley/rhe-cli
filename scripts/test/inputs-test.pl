#!/usr/bin/perl
use strict;
use warnings;

our @Key           = ();
our @Pad           = ();
our $KeyCount      = 0;
our $LineCount     = 0;

print((join " ",@ARGV), "\n");

open KEY, '<', $ARGV[0]
   or die "Couldn't open key.  $!";
while (<KEY>)
{
   chomp;
   @Key = split /,/;
   ++$KeyCount;
}
close KEY;
print((join " ", @Key), "\n");

open PAD, '<', $ARGV[1]
   or die "Couldn't open pad.  $!";
while (<PAD>)
{
   chomp;
   push @Pad, [split //];
   ++$LineCount;
}
close PAD;
foreach my $Row (@Pad)
{
   print @$Row, "\n";
}
