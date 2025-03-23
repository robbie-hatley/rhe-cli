#!/usr/bin/env -S perl -C63
# string-and-test.pl
use v5.36;
use strict;
use warnings;
use utf8;
use List::MoreUtils qw( pairwise );

sub str_and ($x, $y) {
   my $m = length($x);
   my $n = length($y);
   if ($m != $n) {
      die "Error: strings are of unequal length.\n";
   }
   my @xbin = map {ord} split //, $x;
   my @ybin = map {ord} split //, $y;
   my @zbin = pairwise { $a & $b } @xbin, @ybin;
   my $z = join '', map {chr} @zbin;
   return $z;
}

sub bin_print ($x) {
   for (map {ord} split //, $x) {
      printf("%08b ", $_);
   }
   printf "\n";
}

sub str_print ($x) {
   my @charset;
   for (0..255) {
      $charset[$_]=$_;
   }
   @charset[0..31] = map {ord} qw( ␀ ␁ ␂ ␃ ␄ ␅ ␆ ␇ ␈ ␉ ␊ ␋ ␌ ␍ ␎ ␏ ␐ ␑ ␒ ␓ ␔ ␕ ␖ ␗ ␘ ␙ ␚ ␛ ␜ ␝ ␞ ␟ ␠);
   $charset[127] = ord('␡');
   @charset[128..159] = (ord('�')) x 32;
   my $string = join '', map {chr} map { ( $_ < 256 ) ? $charset[$_] : $_} map {ord} split //, $x;
   say $string;
}

my $x = 'U8DeI{_@'; $x = $ARGV[0] if @ARGV >= 1;
my $y = 'mÄ&w5*f/'; $y = $ARGV[1] if @ARGV >= 2;
my $z = str_and($x,$y);
print ' x  str print: '; str_print($x);
print ' y  str print: '; str_print($y);
print 'x&y str print: '; str_print($z);
say '';
print ' x  bin print: '; bin_print($x);
print ' y  bin print: '; bin_print($y);
print 'x&y bin print: '; bin_print($z);
