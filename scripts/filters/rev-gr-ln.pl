#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# rev-gr-ln.pl
# Reverses text, grapheme-by-grapheme, horizontally but not vertically.
# (Doesn't mangle extended grapheme clusters!)
# Input  is from STDIN , or via redirects from files, or via pipes, or via file-name arguments.
# Output is  to  STDOUT, or via redirects from files, or via pipes.
#
# Written by Robbie Hatley.
#
# Edit history:
# Tue Mar 08, 2016: Wrote it.
# Mon Apr 04, 2016: Simplified and now using -CSDA.
# Sat Apr 16, 2016: Fixed line-ending bug and added many comments.
# Sat Dec 16, 2017: Improved comments and help.
# Thu Mar 18, 2021: Now Doesn't mangle extended grapheme clusters.
# Mon Mar 03, 2025: Reduced width from 120 to 110. Got rid of prototypes and empty sigs. Simplified.
# Thu Mar 19, 2026: Changed shebang to "#!/usr/bin/env perl". Now using "utf8::all". Moved to filters.
#                   Renamed from "backwards.pl" to "rev-gr-ln.pl".
#                   Also fixed Perl operator precedence error which was screwing-up newlines.
# Fri Mar 20, 2026: Fixed bug in which checking for help requests was clobbering @ARGV.
# Sat Mar 21, 2026: Now chomps trailing whitespace but leaves leading whitespace intact.
##############################################################################################################

use utf8::all;

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "rev-gr-ln.pl", Robbie Hatley's nifty per-line grapheme reverser.
   This program reverses all text fed to it, horizontally only (not vertically),
   grapheme-by-grapheme.

   WARNING: This program reverses text grapheme-by-grapheme, so that extended
   grapheme clusters (such as in fully-decomposed Vietnamese) are not mangled.
   This means that in some cases, the codepoints will NOT be in reverse order.
   If you need the codepoints to always be in reverse order, use my script
   "rev-cp-ln.pl" instead. To render text with a lot of diacritical marks
   correctly, I recommend a mark-stacking font such as "Inconsolata".

   Command lines:
   rev-gr-ln.pl -h|--help              (prints this help)
   rev-gr-ln.pl                        (reverses text from keyboard)
   rev-gr-ln.pl file1                  (reverses text from file1)
   rev-gr-ln.pl < file1                (reverses text from file1)
   rev-gr-ln.pl < file1 > file2        (reverses text from file1 to file2)
   process1 | rev-gr-ln.pl | process2  (reverses text from process1 to process2)

   Any options or arguments other than -h or --help are ignored.

   All input is from STDIN, or from files named in arguments, or from < or | .
   Input data is not altered (unless user purposely over-writes input using >).

   All output is to STDOUT, or to > or | . Output will be a horizontal (but
   not vertical) reversal of the extended grapheme clusters of the input text.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help

/-h/ || /--help/ and help and exit 777 for @ARGV;

# Use "m/\X/g" to return a list of all eXtended grapheme clusters
# in each line, then reverse and print that list, in forward order:
while(<>) {
   # Get rid of trailing (but not leading) whitespace and control characters:
   s/[\p{Zs}\p{Cc}]+$//;
   # Splice-and-store leading whitespace and control characters:
   my $leader = '';
   if (m/^([\p{Zs}\p{Cc}]+)/) {
      $leader = $1;
      substr $_, 0, length($leader), '';
   }
   # Join leader, reversed text, and newline, and print:
   print $leader . join('', (reverse m/\X/g)) . "\n";
}
