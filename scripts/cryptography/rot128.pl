#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# rot128.pl
# Rot128, an unbreakable cipher by Robbie Hatley.
# See the print_help_msg subroutine for description and instructions.
# Edit history:
#    Tue Nov 15, 2005: Wrote it. (Date is a very loose approximation.)
#    Fri Jul 17, 2015: Converted to utf8.
#    Sun Apr 17, 2016: Undid conversion to utf8.
#    Tue Jan 09, 2018: use v5.026; improved comments.
#    Wed Jan 10, 2018: Removed endline markers; changed data-grabbing
#                      from <> to read(); debugged; corrected errors.
#    Sat May 19, 2018: use v5.30; dramatically improved instructions; and
#                      moved instructions to print_help_msg().
#    Tue Apr 14, 2020: use v5.30 and corrected some minor errors in help.
#    Tue Sep 08, 2020: use v5.30
########################################################################################################################

use v5.32;
use utf8;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

binmode STDIN;
binmode STDOUT;

use RH::Dir;

sub print_help_msg;

# int main (@ARGV)
{
   if (@ARGV == 1 && ($ARGV[0] eq '-h' || $ARGV[0] eq '--help'))
   {
      print_help_msg();
      exit;
   }

   if (@ARGV < 1 || @ARGV > 2)
   {
      warn("Error: rot128.pl takes 1 or 2 arguments.");
      print_help_msg();
      exit;
   }

   our @Pad           = ();
   our @Key           = ();
   my  @InputChars    = ();
   my  @OutputChars   = ();
   my  $OutputChar    = '';
   my  $PadFileName   = '';
   my  $KeyFileName   = '';
   my  $PadSize       = 0;
   my  $KeySize       = 0;
   my  $CharIndex     = 0;
   my  $FoundFlag     = 0;
   my  $Buffer        = '';

   if (@ARGV) {$PadFileName = shift @ARGV;}
   if (@ARGV) {$KeyFileName = shift @ARGV;}

   open(PAD, '< :raw', e $PadFileName) or die "Couldn't open pad.\n$!\n";
   while (1)
   {
      $Buffer = '';
      read(PAD, $Buffer, 256) or last;
      push @Pad, [split //, $Buffer];
      ++$PadSize;
   }
   close PAD;

   warn "\n";
   warn "Pad size = $PadSize\n";
   #warn "Pad:\n";
   #foreach my $ArrayRef (@Pad)
   #{
   #   foreach my $Byte (@{$ArrayRef})
   #   {
   #      printf(STDERR "%2X ", ord($Byte));
   #   }
   #   warn("\n");
   #}

   if ($KeyFileName)
   {
      open(KEY, '<', e $KeyFileName) or die "Couldn't open key.\n$!\n";
      while (<KEY>)
      {
         s/[\x0a\x0d]+$//;
         push @Key, split /,/;
      }
      close KEY;
      $KeySize = scalar @Key;
   }

   else
   {
      @Key = ( 0 .. $PadSize - 1 );
      $KeySize = $PadSize;
   }

   warn "\n";
   warn "Key size = $KeySize\n";
   #warn "Key:\n";
   #foreach (@Key) {printf(STDERR "%d,", $_);}
   #warn "\n";

   warn "\n";
   warn "Encrypted or decrypted text:\n";

   # Immediately before reading the input text, clear the input buffer:
   splice @InputChars;

   # Read the text to be encrypted or decrypted from STDIN
   # (or file redirect, or pipe) and store in array @InputChars :
   LINE_LOOP: while (1)
   {
      $Buffer = '';
      read(STDIN, $Buffer, 100) or last;
      push @InputChars, split //, $Buffer;
   }

   # Clear the @OutputChars array here, preparing it to receive
   # the encoded or decoded version of @InputChars:
   splice @OutputChars;

   # For each character in @InputChars,
   # push encoded version onto @OutputChars:
   CHAR_LOOP: foreach my $InputChar (@InputChars)
   {
      # Select pad row for this character. Note that it pays to keep
      # the total number of characters in the input message less than
      # or equal to the number of rows in the pad, as that keeps the cypher
      # completely unbreakable.
      my $RowNum = $Key[$CharIndex % $KeySize] % $PadSize;
      my @PadRow = @{$Pad[$RowNum]};

      # Set $OutputChar equal to $InputChar and $FoundFlag equal to 0:
      $OutputChar = $InputChar; $FoundFlag = 0;

      # Now loop through the bytes of @PadRow, looking for $InputChar.
      # If $InputChar is found in @PadRow, then set $OutputChar equal to
      # the character on the opposite site of the circle:
      INDEX_LOOP: for (my $i = 0 ; $i < 256 ; ++$i)
      {
         # If $InputChar is in @PadRow, set $OutputChar to the character which
         # is 128 positions around the circle from $InputChar:
         if ($InputChar eq $PadRow[$i])
         {
            $OutputChar = $PadRow[($i+128)%256];
            $FoundFlag = 1;
            last INDEX_LOOP;
         }
      }

      # If $InputChar was not found in @PadRow, warn user that we're outputting
      # the raw input code:
      if (!$FoundFlag)
      {
         warn("WARNING: can't find ordinal ",ord($InputChar)," in pad row.\n");
         warn("Outputing raw input character.\n");
      }

      # Push $OutputChar onto @OutputChars.
      push @OutputChars, $OutputChar;

      # Increment $CharIndex here to indicate 1 more character has been
      # appended to @OutputChars. Since $CharIndex is never reset, and is
      # incremented ONLY here, it is literally "character index within entire
      # input text". Thus each input character gets its own pad line, but not
      # in sequential order (unless no key file was supplied).
      ++$CharIndex;
   } # end CHAR_LOOP

   # Form and print the output string from the output array, using print
   # rather than say, because Rot128 encodes/decodes line-breaks:
   print join '', @OutputChars;

   # We're done, so end program:
   exit;
} # end main()


sub print_help_msg
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "Rot128", an unbreakable cipher by Robbie Hatley.

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ARGUMENTS, INPUT, AND OUTPUT:

   Rot128 takes one or two arguments.

   The first  argument ($ARGV[0]) must be the path to a pad file.
   (See "NOTES" and "PADS" sections below for more info on pad files.)

   The second argument ($ARGV[1]), if present, must be the path to a key file.
   (See "NOTES" and "KEYS" sections below for more info on key files.)

   Input  of material to be encoded or decoded is from stdin.

   Output of encoded or decoded material is to stdout.

   Material to be encoded may be be anything that can be expressed as 8-bit bytes:
   ASCII text, ISO-8859-1 text, UTF-8 text, EBCDIC text, JPG files, BMP files,
   MP3 files, OGG files, EXE files, etc, etc, etc.

   The ciphertexts produced by this program will all look like random 8-bit binary
   gibberish if viewed in a text or binary editor, regardless of input.

   Because this program is "invertible", running encoded material through this
   program a second time with the same pad and key will decode it back to its
   original form.

   Typical usage:
   rot128.pl 'pad.txt' 'key.txt' < plain.txt > cipher.txt

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   NOTES ON THE ROT128 CIPHER:

   The Rot128 cipher uses a "pad" of randomly-permuted arrays the 256-character
   character set consisting of all 256 possible values of a one-byte character.
   I'll call this character set "CHARSET" for the remainder of this document.
   In Perl lingo, CHARSET is:
   our @Charset = map chr, (0..255);

   Each random permutation of CHARSET can be thought of as being a circular array,
   with the end attached to the beginning.  Since there are 256 elements, one
   128-position rotation through this circular array will take us to the far side,
   and another will take us back to where we started. Hence Rot128 is "invertible".

   Rot128 works by comparing each incoming character to one such array. The
   character 128 positions around the circle (ie, the diametracally opposite
   character) is output. All possible 8-bit bytes are in each line of each pad,
   including glyphs, white-space, control characters, iso-8859-1 characters, and
   quite a few "forbidden" characters which are usually not used for anything.
   Hence unlike ROT48, ROT128 encrypts *everything*.

   Since rotating twice takes us back to the beginning, feeding an encrypted
   message back into the program will DE-crypt the message, yielding the
   original plaintext.  Hence this cipher is symmetrical: the decoding
   program/pad/key is the same as the encoding program/pad/key.

   If the number of bytes in the plaintext is not greater than the number of rows
   in the pad, this cipher is completely unbreakable.  Not even the NSA with all
   their supercomputers can't break this cipher, because the characters are truly
   random, so there is no pattern to lock onto. By trial and error, the ciphertext
   could be deciphered to *ANY* same-length plaintext, with no way to determine
   which was the actual original text.

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   PADS:

   To provide a separate, unique random permutation of CHARSET for each incoming
   plaintext character to be encrypted, files called "pads" must be constructed,
   each "pad" consisting of hundreds or thousands of lines of text, each line
   being a unique random permutation of CHARSET.

   Given a pad of at least 500 lines, a 500-character ciphertext could correspond
   to any of (256!)^500 possible plaintexts, and without the pad which was used to
   encrypt the original plaintext, there is no way of determining which of those
   (256!)^500 plaintexts was intended. (In case you're wondering, (256!)^500 is
   about (10^507)^500, or about 10^253500, or a 1 followed by 253500 zeros (about
   79 printed pages filled with all 0s).)

   A Rot128 pad differs from a one-time pad in that each 256-character row of the
   pad encodes only one character of the plaintext, whereas with a one-time pad,
   each character of the key encodes one plaintext character. This cipher has at
   least two advantages over one-time pads. Firstly, it is invertible, in that
   running a text through the cipher twice returns the text to its previous state.
   Secondly, it allows for the lines of the pad to be used in orders other than
   0,1,2,3..., by using a "key" which specifies line order.

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   KEYS:

   To increase security, this cipher can use the lines of the pad in an order
   given by a "key", which is an ASCII text file containing a sequence of
   integers, in the range of the 0-indexed pad row indexes, separated by commas.

   The integers in the key can be in ascending-from-0 order (which is not advised,
   as that would be the same as not using a key at all), or in random order, or a
   permutation of the pad-row indexes, or some combination of those, or some
   other sequence altogether.

   If a good key is used (such as random or permutation order), even if a third
   party gains access to the pad, it will be useless to him unless he also has
   the key, because he will not know which pad line is used for which character
   of the ciphertext. He'd be reduced to trying pad lines on characters at random.

   For example, given a 500-character ciphertext which was encrypted using a pad
   with 500 lines and a key of 500 random numbers in the 0-499 range, even if an
   interloper has the correct pad, he would have to try all 500^500 (3x10^1349)
   possible mappings of pad lines to ciphertext characters. That's far, far more
   astronomical than 1 googol. Even at 1 terraflop, that would take 10^1330 years.
   (The universe is less than 10^10 years old.)

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   EFFECTS OF PLAINTEXT SIZE BEING GREATER THAN PAD SIZE:

   If the number of characters in the plaintext is more than the size of the pad,
   the lines of the pad are reused, starting back at the beginning of the pad.
   (Or, if a key is used, the pattern of pad lines given by the key is reused
   if the size of the ciphertext is larger than the size of the key.) This allows
   for use of pads and keys which are smaller than the texts being encoded, at the
   cost of sacrificing absolute 100% unbreakability.

   However, I think that for a would-be cracker to stand a reasonable chance of
   cracking this cipher, the length of the plaintext would have to be MANY TIMES
   GREATER THAN the key size. And even then, he'd need supercomputers, many hours
   of CPU time, and a lot of luck.  And that's assuming he has already read this
   document! If he hasn't, that decreases his odds enormously.

   Cheers,
   Robbie Hatley,
   Programmer
   END_OF_HELP
   return 1;
}
