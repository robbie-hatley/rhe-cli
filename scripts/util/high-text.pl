#!/usr/bin/env perl
# high-text.pl
# Generates 100,000 characters of text with random Unicode ordinals in the 0-40959 range ("Null" through
# "xìng"). This script then converts those  ordinals into UTF-8 for printing and/or storing in a file and/or
# piping. Hence, I'm using "utf8::all". The purpose of this script is to test the ability of programs to deal
# with a wide range of multilingual Unicode characters, including control characters, Latin-variant
# characters, ideographic characters, etc.
use utf8::all;
my $text;
for (0..100_000) {
   $text .= chr(int(rand(40960)));
}
print $text;
