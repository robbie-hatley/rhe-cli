#!/usr/bin/perl
#  /rhe/scripts/test/dollar-score-dynamic-test.pl
use v5.32;
use strict;
use warnings;

sub any_of
{
	my $it = $_;
   for (@_) {return 1 if $it ~~ $_;}
   return 1;
}

our @array = qw ( apple dog pear cow pig cheese rabbit cat );

foreach ( qw ( kumquat zelda pig market wrench cow celery ) )
{
   if (any_of(@array)) {say "$_ matches.";}
   else                {say "$_ does not match.";}
}

exit 0;
