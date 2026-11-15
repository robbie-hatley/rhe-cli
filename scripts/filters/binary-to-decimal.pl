#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# binary-to-decimal.pl
# Converts binary-number strings, such as "00101001 01 100 011010 1010100 010 101", to decimal representations
# ("41 1 4 26 84 2 5" in the case of that particular example).
# Input  is via STDIN, redirect, pipe, or file-name arguments.
# Output is to  STDOUT.
# As usual for pipeline-style filters, the input is never altered.
# Written by Robbie Hatley.
# Edit history:
# Wed Jan 01, 2020: I probably wrote this in 2020, but I made no record, so I'm not sure.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode"; changed name from "ascii-to-decimal.pl" to "binary-to-decimal.pl";
#                   clarified what this program does; added newline to end of each printed line; and
#                   explicitly specified STDOUT as stream to print to.
# Sat Jul 29, 2023: Reduced width to 110 and cleaned-up these comments.
#                   Also moved this to "filters", because it's designed to be used in a pipeline.
# Fri Aug 02, 2024: Upgraded to "v5.36"; got rid of "common::sense" and "Sys::Binmode".
##############################################################################################################

use v5.36;
use utf8;

while(<>) {
   s/^\s+//; s/\s+$//;
   for my $bin (split / /, $_) {               # Split line on spaces and set $bin to each non-space cluster.
      if ( $bin =~ m/^[01]+$/ ) {              # If $bin is all 1s and 0s, then it's binary,
         printf STDOUT "%d ", oct('0b'.$bin);  # so print its binary representation starting with 0b.
      }
      else {                                   # Otherwise,
         print STDOUT "\x{FFFD} ";             # print Unicode "REPLACEMENT" character followed by a space.
      }
   }
   print STDOUT "\n";                          # Print newline at end of line.
}                                              # Loop to next line, or exit if no more lines.
exit 0;
