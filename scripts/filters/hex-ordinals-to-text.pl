#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# hex-ordinals-to-text.pl
# Converts Unicode codepoints, written as space-separated hexadecimal ordinals, to Unicode text.
# For example: converts "5BCC 58EB 5DDD 753A" to "富士川町".
#
# Written at 11:25PM on Sunday December 5, 2021, by Robbie Hatley.
#
# Edit history:
# Sun Dec 05, 2021: Wrote it.
# Wed Dec 08, 2021: Reformatted titlecard.
# Fri Aug 02, 2024: Upgraded to "v5.36"; got rid of "common::sense"; got rid of "Sys::Binmode".
########################################################################################################################

use v5.36;
use utf8;

for (@ARGV) {
   if ($_ eq '-h' || $_ eq '--help') {
      print
         "Welcome to \"hex-ordinals-to-text.pl\", Robbie Hatley's nifty\n".
         "codepoints-to-text conversion program. This program converts\n".
         "Unicode codepoints, written as space-separated hexadecimal ordinals, to\n".
         "Unicode text. For example: converts \"5BCC 58EB 5DDD 753A\" to \"富士川町\".\n";
      exit 0;
   }
}

while (<>) {
   s/\s+$//;
   for (split / /) {
      if (/^[0-9a-fA-F]+$/) {print chr oct '0x'.$_;}
      else                  {print "\x{FFFD}"     ;}
   }
}
