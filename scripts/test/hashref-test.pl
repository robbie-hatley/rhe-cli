#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
sub GenerateHash
{
my %Hash = ( A => 1 , B => 2 , C => 3 );
return \%Hash;
} # %Hash goes out-of-scope here, BUT!!!
my $hashref = GenerateHash();
say "A => ", $hashref->{A};
say "B => ", $hashref->{B};
say "C => ", $hashref->{C};
# Last reference to %Hash finally goes out-of-scope here, at end of program.
