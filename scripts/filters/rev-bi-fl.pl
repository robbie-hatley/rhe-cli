#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# rev-bi-fl.pl
# Reverses data, bit-by-bit, throughout a file or a stream.
# Input  is from STDIN , or via redirects from files, or via pipes, or via file-name arguments.
# Output is  to  STDOUT, or via redirects from files, or via pipes.
#
# Conjured from the pits of Hell by Robbie Hatley.
#
# Edit history:
# Thu Mar 19, 2026: Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn.
# Fri Mar 20, 2026: Fixed bug in which checking for help requests was clobbering @ARGV.
##############################################################################################################

BEGIN {
   binmode STDIN;
   binmode STDOUT;
}

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "rev-bi-fl.pl", Robbie Hatley's nifty bit reverser.
   This program reverses all data fed to it, bit-by-bit.

   WARNING: This program produces cursed data which will NOT be valid ASCII,
   ISO-8859-1, Unicode, or UTF-8. If you try to print that data, then may
   Cthulhu have mercy on you soul.

   Command lines:
   rev-bi-fl.pl -h|--help              (prints this help)
   rev-bi-fl.pl                        (reverses data from keyboard)
   rev-bi-fl.pl file1                  (reverses data from file1)
   rev-bi-fl.pl < file1                (reverses data from file1)
   rev-bi-fl.pl < file1 > file2        (reverses data from file1 to file2)
   process1 | rev-bi-fl.pl | process2  (reverses data from process1 to process2)

   Any options or arguments other than -h or --help are ignored.

   All input is from STDIN, or from files named in arguments, or from < or | .
   Input data is not altered (unless user purposely over-writes input using >).

   All output is to STDOUT, or to > or | . Output will be a file-wide bit-by-bit
   reversal of the input.

   Interesting fact: This program is non-lossy and reversible, so if you run this
   program on a piece of data twice, the data will return to its original state.

   Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help

/-h/ || /--help/ and help and exit 777 for @ARGV;

# Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn:
my $input = do {local $/;<>};
my @bytes = split //, $input;
my @reversed_bytes = reverse @bytes;
for my $byte (@reversed_bytes) {
   my $old = ord($byte);
   my $new = 0;
   $new |= (($old & 0x01) << 7);
   $new |= (($old & 0x02) << 5);
   $new |= (($old & 0x04) << 3);
   $new |= (($old & 0x08) << 1);
   $new |= (($old & 0x10) >> 1);
   $new |= (($old & 0x20) >> 3);
   $new |= (($old & 0x40) >> 5);
   $new |= (($old & 0x80) >> 7);
   $byte = chr($new);
}
my $Cthulhu = join '', @reversed_bytes;
print $Cthulhu;
