#!/usr/bin/env perl
# cats.pl
use utf8::all;
my @茶 = glob '*';
foreach my $茶 (@茶) {
   print "\n";
   my $金 = undef;
   open($金, "-|", "cat", "-n", $茶) or warn "Couldn't open file \"$茶\".\n" and next;
   print "Contents of file \"$茶\":\n";
   print while <$金>;
   close $金;
}
