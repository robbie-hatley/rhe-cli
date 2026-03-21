#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# rev-cp-ln.pl
# Reverses text, codepoint-by-codepoint, horizontally but not vertically.
#
# Input  is from STDIN , or via redirects from files, or via pipes, or via file-name arguments.
# Output is  to  STDOUT, or via redirects from files, or via pipes.
#
# Written by Robbie Hatley.
#
# Edit history:
# Tue Mar 08, 2016: Wrote it.
# Tue Nov 09, 2021: Refreshed shebang, colophon, and boilerplate.
# Wed Dec 08, 2021: Reformatted titlecard.
# Thu Dec 09, 2021: Simplified.
# Sun Aug 04, 2024: Reduced width from 120 to 110. Upgraded from "v5.32" to "v5.36". Added "use utf8".
#                   Got rid of "common::sense" and "Sys::Binmode".
# Fri Nov 28, 2025: Now using "utf8::all". Now using simplified shebang. Upgraded from "v5.36" to "v5.42".
#                   Now using "print" instead of "say". Added help.
# Sat Nov 29, 2025: Downgraded from "v5.42" to "v5.16", because we're not using any features that weren't in
#                   "v5.16", so we might as well allow a wider range of Perl versions to be used.
#                   Renamed program to "reverse-codepoints.pl" to be more specific about what gets reversed.
# Thu Mar 19, 2026: Spun-off "reverse-codepoints-within lines.pl" and "reverse-codepoints-within-file.pl"
#                   from "reverse-codepoints.pl". Got rid of "use v5.16" (now works with any Perl version).
# Fri Mar 20, 2026: Fixed bug in which checking for help requests was clobbering @ARGV. Changed name of
#                   program from "reverse-codepoints-within-lines.pl" to "rev-cp-ln.pl".
##############################################################################################################

use utf8::all;

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "rev-cp-ln.pl", Robbie Hatley's nifty per-line codepoint reverser.
   This program reverses all text fed to it, horizontally but not vertically,
   codepoint-by-codepoint.

   WARNING: This program reverses text codepoint-by-codepoint, so don't use it
   for text with extended grapheme clusters, such as fully-decomposed Vietnamese,
   unless you truly don't care that the diacritical marks get attached to the
   wrong base characters. To reverse each line of text grapheme-by-grapheme,
   use my script "rev-gr-ln.pl" instead. I recommend using a mark-stacking font
   such as Inconsolata to view text with a lot of diacritical marks.

   Command lines:
   rev-cp-ln.pl -h|--help              (prints this help)
   rev-cp-ln.pl                        (reverses text from keyboard)
   rev-cp-ln.pl file1                  (reverses text from file1)
   rev-cp-ln.pl < file1                (reverses text from file1)
   rev-cp-ln.pl < file1 > file2        (reverses text from file1 to file2)
   process1 | rev-cp-ln.pl | process2  (reverses text from process1 to process2)

   Any options or arguments other than -h or --help are ignored.

   All input  is from STDIN, or from files named in arguments, or from < or | .
   Input data is not altered (unless user purposely over-writes input using >).

   All output is to STDOUT, or to > or | . Output will be a bottom-to-top AND
   right-to-left reversal of the extended grapheme clusters of the input text.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help ()

/-h/ || /--help/ and help and exit 777 for @ARGV;

print join '', reverse split // for <>
