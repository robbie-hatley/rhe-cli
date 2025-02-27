#!/usr/bin/env perl
use v5.16;
my $int_var = 17;
my $chr_var = 'a';
my @queue = (); # Empty queue.
push @queue, "Message #1";
push @queue, "Message #2";
push @queue, "Message #3";
while (@queue) {
   say shift @queue;
}
say "$int_var";
say "$chr_var";
