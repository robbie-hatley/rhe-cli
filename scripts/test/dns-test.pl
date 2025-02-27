#!/usr/bin/perl
use strict;
use warnings;
my $Valid = '[0-9a-z-]{2,63}';
my $Regex = qr{\b(($Valid\.){1,62}$Valid)/};
while (<>)
{
   if ( $_ !~ m/http/ and $_ =~ m/$Regex/ )
	{
	   s%$Regex%http://$1%i;
   }
	print;
}

