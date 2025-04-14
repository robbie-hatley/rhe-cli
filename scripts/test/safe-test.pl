#!/usr/bin/env perl
# safe-test.pl
# Time-tests various subroutines for making characters with ordinals in the
# 0-31 range safe and visible. Sends input text to subroutines formatted as
# a list of lines.

use utf8::all;
use Time::HiRes 'time';

# Shall we debug?
my $db = 0;

# Use list? (Default is no, use scalar.)
my $List  = 0;
my $Input = "Scalar";
for ( my $i = 0 ; $i <= $#ARGV ; ++$i ) {
   local $_ = $ARGV[$i];
   if ( /^-/ ) {
      if ( /^-l$/ || /^--list$/   ) { $List = 1 ; $Input = "List"   }
      if ( /^-s$/ || /^--scalar$/ ) { $List = 0 ; $Input = "Scalar" } # DEFAULT
   }
   splice @ARGV, $i, 1;
   --$i;
}

# Render control codes with ordinals 0x00 through 0x1f visible and safe,
# by adding 0x2400 to their ordinals:
my $forbid = join '', map {chr} (    0 ..   31 ,  127 );
my $replac = join '', map {chr} ( 9216 .. 9247 , 9249 );
sub safe1 {
   local $_ = shift;
   eval("tr/$forbid/$replac/");
   return $_;
}

# Render control codes with ordinals 0x00 through 0x1f visible and safe,
# by adding 0x2400 to their ordinals:
sub safe2 {
   my $text = shift;
   foreach my $idx (0..length($text)-1) {
      my $o = ord(substr($text,$idx,1));
      if ( $o < 32 || 127 == $o ) {
         substr($text, $idx, 1, chr($o+0x2400));
      }
   }
   return $text;
}

# Render control codes with ordinals 0x00 through 0x1f visible and safe,
# by adding 0x2400 to their ordinals:
sub safe3 {
   join '', map {chr} map {32 > $_ || 127 == $_ ? $_ + 0x2400 : $_} map {ord} split(//,shift);
}

# Render control codes with ordinals 0x00 through 0x1f visible and safe,
# by adding 0x2400 to their ordinals:
sub safe4 {
   my $text = shift;
   $text =~ s/([\x00-\x1f\x7f])/chr(ord($1)+0x2400)/eg;
   return $text;
}

# Get lines of test text and dump them into an array variable called "lines":
my @lines = <>;

# Also dump lines into a giant scalar block of text:
my $text = join '', @lines;

# Make a scalar variable called "$safe" to hold the joined output from a "safe" routine:
my $safe;

# Make timer variables:
my ($t0, $t1, $ms); # time 0, time 1, time elapsed in ms

# Make array of methods:
my @methods =
(
   [\&safe1, 1, "(translit)  "],
   [\&safe2, 2, "(substring) "],
   [\&safe3, 3, "(split/join)"],
   [\&safe4, 4, "(regexp)    "],
);

# Test all methods:
foreach my $method (@methods) {
   print "\n\n\n\n\n" if $db;
   $t0 = time;
   if ($List) {
      $safe = join '', map {&{$method->[0]}($_)} @lines;
   }
   else {
      $safe = &{$method->[0]}($text);
   }
   $t1 = time;
   $ms = 1000 * ($t1 - $t0);
   if ($db) {
      print "Text from method $method->[1]:\n";
      print $safe;
      print "\n";
   }
   printf "Elapsed time for method %d %s using %s input = %9.3fms\n", $method->[1], $method->[2], $Input, $ms;
}
