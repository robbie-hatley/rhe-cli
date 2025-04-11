#!/usr/bin/perl
# camel-01-test.pl
use Artiodactyla::Camelini qw( camel $weight );

my $type  = camel;
my $mass  = $weight;
print "My camel is a $type and weighs ${mass}LB.\n";
