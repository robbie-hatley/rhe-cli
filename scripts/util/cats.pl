#!/usr/bin/env perl
# cats.pl
use v5.16;
use utf8::all;
my @茶 = glob '*';
foreach my $茶 (@茶) {
   say '';
   say "Contents of file \"$茶\":";
   my $金 = undef;
   open($金, "-|", "cat -n $茶")
      or  warn "Couldn't open file \"$茶\".\n"
      and next;
   foreach my $銀 (<$金>) {
      print "$銀";
   }
}
