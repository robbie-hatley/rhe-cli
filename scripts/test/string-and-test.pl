#!/usr/bin/env -S perl -C63
# string-and-test.pl
use v5.36;
use strict;
use warnings;
use utf8;
use List::MoreUtils qw( pairwise );

sub str_and ($x, $y) {
   if (length($x) != length($y)) {
      die "Error: strings are of unequal length.\n";
   }
   my @xbin = map {ord} split //, $x;
   my @ybin = map {ord} split //, $y;
   my @zbin = pairwise { $a & $b } @xbin, @ybin;
   return join '', map {chr} @zbin;
}

sub bin_print ($x) {
   for my $ord (map {ord} split //, $x) {
      # 1 byte:
      if ($ord < 2**8) {
         printf("%08b ", $ord);
      }
      # 2 bytes:
      elsif ($ord < 2**16) {
         printf("%016b ", $ord);
      }
      # 3 bytes:
      elsif ($ord < 2**24) {
         printf("%024b ", $ord);
      }

      # 4 bytes:
      elsif ($ord < 2**32) {
         printf("%032b ", $ord);
      }
   }
   print "\n";
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
