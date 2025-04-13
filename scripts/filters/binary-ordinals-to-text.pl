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

# Die if any line of input is invalid:
foreach my $idx (0..$#lines) {
   if ($lines[$idx] !~ m/^[01 \n]$/) {
      die "Fatal error in \"binary-ordinals-to-tex.pl\": Invalid characters on line $idx.\n"
         ."(Input should contain zeros, ones, spaces, and newlines only.)\n";
   }
}

foreach my $line (@lines) {
   $line s/\s+$//;
   for (split / /) {
      if (/^[01]+$/) {print chr oct '0b'.$_;}
      else           {print "\x{FFFD}"     ;}
   }
}
