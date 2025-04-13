#!/usr/bin/env perl
# low-text-2.pl
# Generates 1000100 bytes of text consisting of 100 lines of
# 10,001 characters, with the characters of each line being
# 10,000 random ordinals in the 0-63 range ("Null" through
# "Question") followed by one newline. The purpose of this
# is to time-test subroutines for making characters with
# ordinals in the 0-31 range safe and visible.
my $text;
for my $row (0..100) {
   for my $col (0..10_000) {
      my $char = chr(int(rand(64)));
      $text .= $char;
   }
   $text .= "\n";
}
print $text;
