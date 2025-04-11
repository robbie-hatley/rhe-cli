#!/usr/bin/perl
# camel-01-test.pl
use Artiodactyla::Camelidae;
my $camel = Artiodactyla::Camelidae->new;
my $type  = $camel->camel;
my $mass  = $camel->weight;
print "My camel is a $type and weighs ${mass}LB.\n";
