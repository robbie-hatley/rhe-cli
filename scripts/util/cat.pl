#!/usr/bin/env perl
# cat.pl
use utf8::all;
exit unless 1 == scalar @ARGV;
my $茶 = $ARGV[0];
my $金;
open($金, "-|", "cat", "-n", $茶) or die "Couldn't open file.\n";
while (<$金>) {
   print;
}
