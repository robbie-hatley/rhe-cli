#!/usr/bin/perl
#  underline-test.pl
use v5.32;
use Term::ANSIColor qw(:constants);
my $text = "Now is the time!";
print UNDERLINE;
say $text;
print RESET;
exit 0;
