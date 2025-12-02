#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# reverse-graphemes.pl
# Reverses text, grapheme-by-grapheme, both horizontally and vertically.
#
# Text is input  from STDIN , or via redirects from files, or via pipes, or via file-name arguments.
# Text is output to   STDOUT, or via redirects from files, or via pipes.
#
# Written by Robbie Hatley.
#
# Edit history:
# Thu Mar 18, 2021: Wrote it.
# Fri Nov 28, 2025: Reduced width from 120 to 110. Now using "utf8::all". Simplified shebang.
#                   Renamed to "reverse-graphemes.pl" to avoid conflict with "reverse.pl".
#                   Moved from "humor" to "filters" as this is a useful utility filter.
#                   No longer tampers with whitespace. Now uses "print" instead of "say".
# Sat Nov 29, 2025: Downgraded from "v5.42" to "v5.16", because we're not using any features that weren't in
#                   "v5.16", so we might as well allow a wider range of Perl versions to be used.
##############################################################################################################

use v5.16;
use utf8::all;

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "reverse-graphemes.pl", Robbie Hatley's nifty grapheme reverser.
   This program reverses all text fed to it, both horizontally AND vertically,
   grapheme-by-grapheme.

   WARNING: This program reverses text grapheme-by-grapheme, so that extended
   grapheme clusters (such as in fully-decomposed Vietnamese) are not mangled.
   This means that in some cases, the codepoints will NOT be in reverse order.
   If you need the codepoints to always be in reverse order, use my script
   "reverse-codepoints.pl" instead. To render mark-stacking correctly, use
   a suitable font, such as "Inconsolata".

   Command lines:
   reverse-graphemes.pl -h|--help              (prints this help)
   reverse-graphemes.pl                        (reverses text from keyboard)
   reverse-graphemes.pl file1                  (reverses text from file1)
   reverse-graphemes.pl < file1                (reverses text from file1)
   reverse-graphemes.pl < file1 > file2        (reverses text from file1 to file2)
   process1 | reverse-graphemes.pl | process2  (reverses text from process1 to process2)

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

for (@ARGV) {
   if($_ eq '--help' || $_ eq '-h') {
      help;
      exit;
   }
}

print join '', reverse $_ =~ m/\X/g for reverse <>
