#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# text-to-binary-ordinals.pl
# Converts Unicode-encoded UTF-8-transformed text to the raw Unicode codepoints of its characters,
# then prints the Unicode codepoints in binary.
# For example, this script converts "富士川町" to
# "0101101111001100 0101100011101011 0101110111011101 0111010100111010".
# (For the reverse, see my script "binary-ordinals-to-text.pl".)
#
# Written circa 2020 by Robbie Hatley.
#
# Edit history:
# ??? ??? ??, ????: I probably wrote this some time in 2020, but I made no record, so I'm not sure.
# Tue Nov 09, 2021: Refreshed shebang, colophon, and boilerplate.
# Wed Dec 08, 2021: Reformatted titlecard.
# Sun Aug 04, 2024: Increased min ver from "5.32" to "5.36"; got rid of "common::sense" and "Sys::Binmode".
# Sun Apr 13, 2025: Now using "utf8::all". Simplified shebang to "#!/usr/bin/env perl". Nixed min ver.
##############################################################################################################

use utf8::all;
use POSIX 'ceil';

my $lbits = 0;                                      # Bits printed so-far on this line.
my $bytes = 0;                                      # Bytes printed so-far.
my $Index = 0;                                      # Use hex byte index column on left?

for ( my $i = 0 ; $i <= $#ARGV ; ++$i ) {           # Riffle through @ARGV.
   local $_ = $ARGV[$i];                            # Set a local copy of $_ to current @ARGV element.
   if (/^-/) {                                      # If element begins with hyphen,
      /^-i$/ || /^--index$/ and $Index = 1;         # set $Index if element is "-i" or "--index"
      splice @ARGV, $i, 1;                          # and remove element from @ARGV (else fouls-up "<>")
      --$i;                                         # and backtrack due to deletion to avoid skipping.
   }
}

while (<>) {                                        # Riffle through input from STDIN, files, or pipes.
   foreach my $c (split //) {                       # Split each line and riffle through its characters.
      my $ord = ord($c);                            # Get the ordinal of the current character.
      my $len = $ord < 256 ? 8 :                    # Get length-in-bits of ordinal, minimum 8 bits,
      8 * int(ceil(log($ord+1)/log(256)));          # rounded up to a muliple of 8 bits.
      if ($lbits + $len >  64) {                    # If we're about to go over 64 bits,
         $lbits = 0;                                # reset line-bits counter
         print "\n";                                # and print newline now to prevent overrunning 78 columns
      }                                             # even if we're using indexing.
      if ($Index && 0 == $lbits) {                  # If indexing is turned on and we're beginning a line,
         printf("%04x  ", $bytes);                  # print hex byte index offset.
      }
      printf("%0${len}b ", $ord);                   # Print ordinal for current character in binary.
      $lbits += $len;                               # Add # of bits  just printed to  line-bits  counter.
      $bytes += $len/8;                             # Add # of bytes just printed to total-bytes counter.
   }
}
print "\n";                                         # Print a final newline at end.
