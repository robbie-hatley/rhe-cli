#!/usr/bin/env perl
# reverse-bits.pl
use v5.36;
use Scalar::Util qw( looks_like_number );
sub reverse_bits ($x) {
   my $rev = 0;
   for (0..7) {$rev += 128 >> $_ if $x & 1 << $_ ;}
   return $rev;
}
exit if 1 != @ARGV;
exit if !looks_like_number($ARGV[0]);
my $n = int($ARGV[0]+0);
exit if $n < 0;
exit if $n > 255;
say reverse_bits $ARGV[0];
