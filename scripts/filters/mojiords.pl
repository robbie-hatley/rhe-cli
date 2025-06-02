#!/bin/perl
##############################################################################################################
# mojibake.pl
# Converts STDIN to mojibake numeric ordinals.
# Written by Robbie Hatley.
# Edit history:
# Wed May 28, 2025: Wrote it.
##############################################################################################################
use v5.36;
binmode STDIN,  ":raw";  # Purposely misinterpret UTF-8 as being raw unicode, inbound.
binmode STDOUT, ":utf8"; # Print normally, outbound.

# Separate elements of an array in a quote with spaces:
$" = ' ';

# Print the Unicode codepoints of the fake single-byte "characters" (mojibake) we just input:
for my $line (<STDIN>) {
   $line =~ s/\s+$//;
   my @chars = split //, $line;
   my @ords = map {ord($_)} @chars;
   say "@ords";
}
