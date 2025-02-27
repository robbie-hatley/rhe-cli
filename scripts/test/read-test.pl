#!/usr/bin/perl
use strict;
use warnings;

our @Key;
our @PermCharsets;
our @IChars;
our @OChars;
our $OString;
our $CharCount = 0;

open PAD, '<', 'E:\scripts\pad.txt'
   or die "Sorry, Dave, I'm afraid I can't do that.  $!";

while (<PAD>)
{
   chomp;
   push @PermCharsets, [split //,$_];
}

for my $Charset (@PermCharsets)
{
   print (@$Charset, "\n");
}
