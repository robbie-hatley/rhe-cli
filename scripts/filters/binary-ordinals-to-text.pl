#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# binary-ordinals-to-text.pl
# Converts Unicode codepoints, written as space-separated hexadecimal ordinals, to Unicode text.
# For example: converts "0101101111001100 0101100011101011 0101110111011101 0111010100111010" to "富士川町".
# (For the reverse, see my script "binary-ordinals-to-text.pl".)
#
# Written (in 2020?) by Robbie Hatley.
#
# Edit history:
# Wed Jan 01, 2020: I probably wrote this in 2020, but I made no record, so I'm not sure.
# Tue Nov 09, 2021: Refreshed shebang, colophon, and boilerplate.
# Wed Dec 08, 2021: Reformatted titlecard.
# Fri Aug 02, 2024: Increased min ver from "5.32" to "5.36"; got rid of "common::sense" and "Sys::Binmode".
# Sun Apr 13, 2025: Now using "utf8::all"; simplified shebang to "#!/usr/bin/env perl".
##############################################################################################################

use utf8::all;

# Get lines of binary ordinals:
my @lines = <>;

# Die if any line of input contains any characters except zeros, ones, spaces, and ending newlines:
foreach my $idx (0..$#lines) {                # Riffle through indexs of @lines.
   local $_ = $lines[$idx];                   # Set local copy of $_ to current line.
   chomp;                                     # Delete ending newline if any.
   /^[01 ]*$/                                 # Remainder should be zeros, ones, and spaces only, else die.
   or die "Fatal error in \"binary-ordinals-to-tex.pl\": Invalid characters on line $idx.\n"
         ."(Input should contain zeros, ones, spaces, and newlines only.)\n";
}

for (@lines) {                                # Riffle through @lines, setting $line to each line in turn.
   chomp;                                     # Delete ending newline, if present, from current line.
   for my $cluster (split / /) {              # Split line into clusters of 0s and 1s and riffle through them.
      my $o = oct( '0b' . $cluster );         # Get ordinal from cluster.
      if    ((32 > $o || 127 == $o)           # If control character
             && 9 != $o && 10 != $o) {        # other than tab or newline,
         print chr(9216+$o);                  # print visual representation.
      }
      elsif (127 < $o && $o < 160) {          # If extended control character,
         print chr($o+0x1FA80);               # print some weird blocky black angular symbols.
      }
      elsif ($o > 0x10FFFF) {                 # If out-of-range,
         print '�';                           # print replacement character "\x{FFFD}".
      }
      else {                                  # Otherwise,
         print(chr($o));                      # print character mapped-to by ordinal.
      } # end else (print char)
   } # end for (each ordinal)
} # end for (each line)
