#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
use utf8;
use open qw( :encoding(utf8) :std );
use charnames qw(:full);
use Unicode::Normalize qw(NFD NFC);

our @o =
(
   "\x{F5}",
   "o\x{303}",
   "\x{22D}",
   "\x{F5}\x{304}",
   "o\x{303}\x{304}",
   "o\x{304}\x{303}",
   "\x{14D}\x{303}"
);

say join ' ', @o;

foreach (@o)
{
   my $m = $_;
   my $n = NFD($_);
   my $myn = ($m =~ m/^o\p{Mn}*$/) ? 'Yes' : 'No';
   my $nyn = ($n =~ m/^o\p{Mn}*$/) ? 'Yes' : 'No';
   printf("%3s%3s  %3s  %3s\n", $m, $n, $myn, $nyn);
}
