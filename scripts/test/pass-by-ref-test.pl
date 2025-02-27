#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
sub change
{
	my $x = shift;
	$x->{name} = "new";
}
my %thing = (name => "old");
change(\%thing);
print $thing{name}, "\n";
