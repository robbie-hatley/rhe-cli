#!/usr/bin/env perl
# low-text.pl
# Generates 100,000 characters of text with random Unicode ordinals in the 0-255 range ("Null" through
# "Latin Small Letter Y with diaeresis"). The purpose of this is to time-test subroutines for making
# characters with ordinals in the (0..31,127) range safe and visible. This script then converts those
# ordinals into UTF-8 for printing and/or storing in a file and/or piping. Hence, I'm using "utf8::all".
use utf8::all;
my $text;
for (0..100_000) {
   $text .= chr(int(rand(256)));
}
print $text;
