#!/usr/bin/env perl
# safe-test.pl
# Time-tests various subroutines for making characters with ordinals in the
# 0-31 range safe and visible.

use Time::HiRes 'time';

# Render control codes with ordinals 0x00 through 0x1f visible and safe,
# by adding 0x2400 to their ordinals:
my $forbid;
$forbid .= "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f";
$forbid .= "\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f";
my $replac;
$replac .= "\x{2400}\x{2401}\x{2402}\x{2403}\x{2404}\x{2405}\x{2406}\x{2407}";
$replac .= "\x{2408}\x{2409}\x{240a}\x{240b}\x{240c}\x{240d}\x{240e}\x{240f}";
$replac .= "\x{2410}\x{2411}\x{2412}\x{2413}\x{2414}\x{2415}\x{2416}\x{2417}";
$replac .= "\x{2418}\x{2419}\x{241a}\x{241b}\x{241c}\x{241d}\x{241e}\x{241f}";
sub safe1 {
   local $_ = shift;
   return eval("tr/$forbid/$replac/r");
}

# Render control codes with ordinals 0x00 through 0x1f visible and safe,
# by adding 0x2400 to their ordinals:
sub safe2 {
   my $text = shift;
   foreach my $idx (0..length($text)-1) {
      my $o = ord(substr($text,$idx,1));
      if ( $o < 32 ) {
         substr($text, $idx, 1, chr($o+0x2400));
      }
   }
   return $text;
}

# Render control codes with ordinals 0x00 through 0x1f visible and safe,
# by adding 0x2400 to their ordinals:
sub safe3 {
   join '',
   map {chr}
   map {$_ < 32 ? $_ + 0x2400 : $_}
   map {ord}
   split(//,shift);
}

# Render control codes with ordinals 0x00 through 0x1f
# visible and safe, by adding 0x2400 to their ordinals:
sub safe4 {shift =~ s/([\x00-\x1F]{1})/chr(ord($1)+0x2400)/egr}

# Get lines of test text:
my @lines = <>;
my @safe;

# Make timer variables:
my ($t0, $t1, $ms); # time 0, time 1, time elapsed in ms

# Test method 1:
$t0 = time;
@safe = map {safe1} @lines;
$t1 = time;
$ms = 1000 * ($t1 - $t0);
printf("Elapsed time for method 1 = %7.3fms\n", $ms);

# Test method 2:
$t0 = time;
@safe = map {safe2} @lines;
$t1 = time;
$ms = 1000 * ($t1 - $t0);
printf("Elapsed time for method 2 = %7.3fms\n", $ms);

# Test method 3:
$t0 = time;
@safe = map {safe3} @lines;
$t1 = time;
$ms = 1000 * ($t1 - $t0);
printf("Elapsed time for method 3 = %7.3fms\n", $ms);

# Test method 4:
$t0 = time;
@safe = map {safe4} @lines;
$t1 = time;
$ms = 1000 * ($t1 - $t0);
printf("Elapsed time for method 4 = %7.3fms\n", $ms);
