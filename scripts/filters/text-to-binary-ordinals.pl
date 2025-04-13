#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# text-to-binary-ordinals.pl
# Converts Unicode-encoded text to the raw Unicode codepoints (NOT UTF-8!) of its characters, in binary.
# For example, converts "富士川町" to "0101101111001100 0101100011101011 0101110111011101 0111010100111010".
# (For the reverse, see my script "binary-ordinals-to-text.pl".)
#
# Written (in 2020?) by Robbie Hatley.
#
# Edit history:
# Wed Jan 01, 2020: I probably wrote this in 2020, but I made no record, so I'm not sure.
# Tue Nov 09, 2021: Refreshed shebang, colophon, and boilerplate.
# Wed Dec 08, 2021: Reformatted titlecard.
# Sun Aug 04, 2024: Increased min ver from "5.32" to "5.36"; got rid of "common::sense" and "Sys::Binmode".
# Sun Apr 13, 2025: Now using "utf8::all"; simplified shebang to "#!/usr/bin/env perl".
##############################################################################################################

use utf8::all;
use POSIX 'ceil';

my $lbits = 0;                                      # Bits printed so-far on this line.
my $bytes = 0;                                      # Bytes printed so-far.

while (<>)
{
   for (split //)
   {
      my $ord = ord;
      my $len = 8 * int ceil (log($ord)/log(256));  # Get length-in-bits of next ordinal to be printed.
      if ($lbits + $len >  64) {                    # If we're about to go over 64 bits,
         $lbits = 0;                                # reset line-bits counter
         print "\n";                                # and print newline now to prevent overrun.
      }
      if (0 == $lbits) {printf("%04x  ", $bytes);}  # If we're beginning a line, print hex byte index offset.
      printf("%0${len}b ", $ord);                   # Print ordinal for current character in binary.
      $lbits += $len;                               # Add bits for char just printed to line-bits counter
      $bytes += $len/8;                             # and add bytes to total-bytes counter.
   }
}
print "\n"; # Print final newline at end.
