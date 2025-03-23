#!/usr/bin/env -S perl -C63
# string-and-test.pl
use v5.36; use utf8; no strict; no warnings;
sub bin ($x) {
   die "over 64 bits\n" if length $x > 8;
   my @chars = split '', $x;
   my $bin = 0;
   for my $char (@chars) {
      $bin = ($bin << 8) + ord $char;
   }
   return(0 + $bin);
}
sub str_and ($x, $y) {
   die "Error: First  string is more than 8 bytes.\n" if length $x > 8;
   die "Error: Second string is more than 8 bytes.\n" if length $y > 8;
   my $xbin = bin($x);
   my $ybin = bin($y);
   my $zbin = $xbin & $ybin;
   my $zstr = '';
   $zstr .= chr((0xff00000000000000 & $zbin) >> 56);
   $zstr .= chr((0x00ff000000000000 & $zbin) >> 48);
   $zstr .= chr((0x0000ff0000000000 & $zbin) >> 40);
   $zstr .= chr((0x000000ff00000000 & $zbin) >> 32);
   $zstr .= chr((0x00000000ff000000 & $zbin) >> 24);
   $zstr .= chr((0x0000000000ff0000 & $zbin) >> 16);
   $zstr .= chr((0x000000000000ff00 & $zbin) >>  8);
   $zstr .= chr((0x00000000000000ff & $zbin) >>  0);
   return $zstr;
}
sub bin_print ($x) {
   printf "%08b ", (0xff00000000000000 & $x) >> 56;
   printf "%08b ", (0x00ff000000000000 & $x) >> 48;
   printf "%08b ", (0x0000ff0000000000 & $x) >> 40;
   printf "%08b ", (0x000000ff00000000 & $x) >> 32;
   printf "%08b ", (0x00000000ff000000 & $x) >> 24;
   printf "%08b ", (0x0000000000ff0000 & $x) >> 16;
   printf "%08b ", (0x000000000000ff00 & $x) >>  8;
   printf "%08b\n",(0x00000000000000ff & $x) >>  0;
}
sub str_print ($x) {
   my @chars = split //, $x;
   my @charset;
   for (0..255) {$charset[$_]=chr($_)}
   @charset[0..31] = qw( ␀ ␁ ␂ ␃ ␄ ␅ ␆ ␇ ␈ ␉ ␊ ␋ ␌ ␍ ␎ ␏ ␐ ␑ ␒ ␓ ␔ ␕ ␖ ␗ ␘ ␙ ␚ ␛ ␜ ␝ ␞ ␟ ␠);
   $charset[127] = '␡';
   @charset[128..159] = ('�') x 32;
   my $string = join '', map {$charset[$_]} map {ord $_} @chars;
   printf "%8s\n", $string;
}
my $x = 'fUre6$Kt'; $x = $ARGV[0] if @ARGV >= 1;
my $y = 'SuB>IL&?'; $y = $ARGV[1] if @ARGV >= 2;
my $z = str_and($x,$y);
print ' x  str print: '; str_print $x;
print ' y  str print: '; str_print $y;
print 'x&y str print: '; str_print $z;
say '';
print ' x  bin print: '; bin_print bin($x);
print ' y  bin print: '; bin_print bin($y);
print 'x&Y bin print: '; bin_print bin($z);
