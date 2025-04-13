#!/usr/bin/env perl
# low-text.pl
# Generates 800KB of text consisting of characters with
# random ordinals in the 0-63 range ("Null" through "Question").
# The purpose of this is to time-test subroutines for making
# characters with ordinals in the 0-31 range safe and visible.
my $text;
for my $row (0..10000) {
   for my $col (0..79) {
      my $char = chr(int(rand(64)));
      $text .= $char;
   }
   $text .= "\n";
}
print $text;
