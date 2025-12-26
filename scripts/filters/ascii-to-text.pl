#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# ascii-to-text.pl
# Construes multi-digit hexadecimal numbers to iso-8859-1 codepoints then prints those characters.
# Input is via STDIN. All white space is erased. Each input line is then split into two-character segments.
# Any segment which is not two characters or does not consist only of [0-9a-fA-F] is printed as "�" (Unicode
# "replacement" character indicating "invalid ordinal").
#
# Written at 11:29AM on Thursady December 25, 2025, by Robbie Hatley.
#
# Edit history:
# Thu Dec 25, 2025: Wrote it.
##############################################################################################################

use v5.36;
use utf8::all;

for (@ARGV) {
   if ($_ eq '-h' || $_ eq '--help') {
      print
         "Welcome to \"ascii-to-text.pl\", Robbie Hatley's nifty ascii-to-text\n".
         "conversion program. This program construes multi-digit hexadecimal numbers\n".
         "as being a sequence of 2-digit hexadecimal numbers representing iso-8859-1\n".
         "codepoints. Input is via STDIN. All white space is erased. Each input line\n".
         "is then split into two-character segments. Any segment which is not two\n".
         "characters, or does not consist only of [0-9a-fA-F], or is not a valid\n".
         "iso-8859-1 ordinal, is printed as \"�\" (Unicode \"replacement\" character\n".
         "indicating \"invalid ordinal\"). All other hexadecimal digit pairs are\n".
         "printed as their iso-8859-1 characters.";
      exit 777;
   }
}

while (<STDIN>) {
   # Chomp BOM (if any) from beginning of $_:
   s/^\N{BOM}//;
   # Chomp newline (if any) from end of $_:
   chomp;
   # Get rid of all white space, everywhere, globally:
   s/\s+//g;
   # Get a list of two-hex-digit ASCII ordinals:
   my @hex;
   while (length($_) > 1) {push @hex, substr($_, 0, 2, '')}
   # Print any single-digit remnant as "�":
   if (1==length($_)) {push @hex, '80'}
   for my $two (@hex) {
      # Change any non-hex character pairs to '80' (non-printable; will print as "�"):
      if ($two !~ m/^[0-9a-fA-F]{2}$/) {$two = '80'}
      # At this point, "$two" should be a hexadecimal representation of an integer in the 0-to-255 range.
      # Convert hexadecimal $two to decimal $ord for ease of use with "chr":
      my $ord = oct('0x'.$two);
      # If $ord not printable, print a "�" character instead:
      if ($ord < 10 || ($ord > 10 && $ord < 32) || ($ord > 126 && $ord < 160)) {print "�"}
      # Otherwise, print the character corresponding to decimal iso-8859-1 ordinal $ord:
      else {print(chr($ord))}
   }
}
