#!/usr/bin/perl
use v5.32;
use strict;
use warnings;

sub Sub1 {return "0123456789" =~ m/(\d{3})/g;}
sub Sub2 {return "0123456789" =~ m/(?=(\d{3}))/g;}
sub Sub3 {return "0123456789" =~ m/(?=\d{3})/g;}
our @Subs = (\&Sub1, \&Sub2, \&Sub3);

foreach (0..2) {
   my @m = &{$Subs[$_]};
   my $m = join(' ', @m);
   say $m;
   say scalar(@m);
}
