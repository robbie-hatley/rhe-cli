#!/usr/bin/env perl
# all-chars.pl
# Generates 40,960 characters of text with sequential Unicode ordinals in the 0-40959 range ("Null" through
# "xìng"). This is nearly every single commonly-used character in Unicode! This script then converts those
# characters into UTF-8 for printing and/or storing in a file and/or piping. Hence, I'm using "utf8::all".
#
# The purpose of this script is to generate a chart of all commonly-used characters, to see what they look
# like.
use utf8::all;

# Replace control codes 0-8, 11-31, 127, 128-159 with safe, visible characters:
sub safe {
   my $forbid = join '', map {chr} (    0 ..    8 ,   11 ..   31 ,  127 ,    128 ..    159 );
   my $replac = join '', map {chr} ( 9216 .. 9224 , 9227 .. 9247 , 9249 , 129792 .. 129823 );
   local $_ = shift;
   eval("tr/$forbid/$replac/");
   return $_;
}

my $text;
for my $ordinal (0..40_959) {
   $text .= chr($ordinal);
}
print safe($text);
