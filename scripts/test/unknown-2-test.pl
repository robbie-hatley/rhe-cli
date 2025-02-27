#!/usr/bin/perl
use v5.32;
use strict;
use warnings;

my $Regex1 = q{https?://[a-z]+\.acme\.com};
my $Regex2 = qr{((?:^|(?<=\s))$Regex1)};

while (<>)
{
   say "Combined Regexp = $Regex2";
	if ($_ =~ $Regex2)
	{
	   print "MATCH: $1\n";
	}
	else
	{
	   print "NO MATCH.\n";
	}
}
