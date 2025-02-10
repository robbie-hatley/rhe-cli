#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# rot48.pl
# Rot48, an unbreakable cipher by Robbie Hatley.
# See the print_help_msg subroutine for description and instructions.
# Edit history:
#    Mon Jul 04, 2005: Wrote it. (Date is a loose approximation.)
#    Fri Jul 17, 2015: Converted to utf8.
#    Sun Apr 17, 2016: Undid conversion to utf8.
#    Tue Jan 09, 2018: use v5.026; improved comments.
#    Wed Jan 10, 2018: Debugged & corrected errors.
#    Sat May 19, 2018: use v5.20, dramatically improved instructions, and
#                      moved instructions to print_help_msg().
#    Tue Apr 14, 2020: use v5.30 and corrected some minor errors in help.
########################################################################################################################

use v5.32;
use utf8;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

use RH::Dir;

sub print_help_msg;

# int main (@ARGV)
{
   for ( my $i = 0 ; $i < @ARGV ; ++$i)
   {
      $_ = $ARGV[$i];
      if (/^-[\pL\pN]{1}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/)
      {
         if ($_ eq '-h' || $_ eq '--help')
         {
            print_help_msg();
            exit;
         }
         splice @ARGV, $i, 1; # Remove option from @ARGV.
         --$i; # Re-sync to new item in same spot.
      }
   }

   if (@ARGV < 1 || @ARGV > 2)
   {
      warn("Error: rot48.pl takes 1 or 2 arguments.");
      print_help_msg();
      exit;
   }

   my @Pad          = ();  # One-time pad.
   my @Key          = ();  # Pad row index key.
   my @InputChars   = ();  # Characters to be inputted.
   my @OutputChars  = ();  # Characters to be outputted.
   my $InputChar    = '';  # Input character.
   my $OutputChar   = '';  # Output character.
   my $PadFileName  = '';  # Name of pad file.
   my $KeyFileName  = '';  # Name of key file.
   my $PadSize      =  0;  # Size of pad file.
   my $KeySize      =  0;  # Size of key file.
   my $RowNum       =  0;  # Row    number within pad.
   my $ColNum       =  0;  # Column number within pad.
   my $Ord          =  0;  # Ordinal of current input character.
   my $CharCount    =  0;  # Count of all characters processed.
   my $CrypCount    =  0;  # Count of all characters encrypted/decrypted.
   my $FeedCount    =  0;  # Count of all characters fed-through verbatim.
   my $FoundFlag    =  0;  # Did we find input character in pad row?

   if (@ARGV) {$PadFileName = shift @ARGV;}
   if (@ARGV) {$KeyFileName = shift @ARGV;}

   open(PAD, '<', e $PadFileName) or die "Couldn't open pad.\n$!\n";
   while (<PAD>)
   {
      s/[\x0a\x0d]+$//;
      push @Pad, [split //];
      ++$PadSize;
   }
   close PAD;

   warn "Pad size = $PadSize\n";
   #warn "Pad:\n";
   #warn join '', @{$_}, "\n" for @Pad;

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

   warn "Key size = $KeySize\n";
   #warn "Key:\n";
   #foreach (@Key) {printf(STDERR "%d,", $_);}
   #warn "\n";

   # Immediately before reading the input text, clear the input buffer:
   splice @InputChars;

   # Read the text to be encrypted or decrypted from STDIN
   # (or file redirect, or pipe) and store in array @InputChars :
   LINE_LOOP: while (<>)
   {
      # Don't strip-off line-break characters, just leave them in-place;
      # they'll be fed-through as-is because they're not in our standard
      # character set (9, 32..126). Split current line into characters and
      # dump those characters into @InputChars:
      push @InputChars, split //, $_;
   }

   # Clear the @OutputChars array here, preparing it to receive
   # the encoded or decoded version of @InputChars:
   splice @OutputChars;

   # For each character in @InputChars,
   # push encoded version onto @OutputChars:
   CHAR_LOOP: foreach $InputChar (@InputChars)
   {
      # If this character is not in the ASCII subset {9, 32-126}, feed it
      # through verbatim and do not use-up a pad row:
      $Ord = ord($InputChar);
      if (!($Ord == 9 || $Ord>=32 && $Ord<=126))
      {
         $OutputChar = $InputChar;
         ++$FeedCount;
      } # end if input character is not in standard character set

      # Otherwise, select a pad row for this character:
      else
      {
         # Select pad row to use for this character:
         $RowNum = $Key[$CrypCount % $KeySize] % $PadSize;

         # Reset $FoundFlag to 0 immediately before looking for input char in pad row:
         $FoundFlag = 0;

         # Now loop through the bytes of @PadRow, looking for $InputChar.
         # If $InputChar is found in @PadRow, then set $OutputChar equal to
         # the character on the opposite site of the circle:
         for ($ColNum = 0 ; $ColNum < 96 ; ++$ColNum)
         {
            # If $InputChar is in @PadRow, set $OutputChar to the character which
            # is 48 positions around the circle from $InputChar:
            if ($InputChar eq $Pad[$RowNum]->[$ColNum])
            {
               $FoundFlag = 1;
               last;
            }
         }

         # If $InputChar was found in current pad row, rotate it to the
         # opposite side of the circle (so that another rotation will
         # restore it to original):
         if ($FoundFlag)
         {
            $OutputChar = $Pad[$RowNum]->[($ColNum+48)%96];
            ++$CrypCount;
         }

         # Otherwise, a severe error has occurred; output the input character
         # verbatim and warn user:
         else
         {
            # NOTE: THIS IS IMPOSSIBLE, AND WE SHOULD NEVER GET HERE!
            # IF WE DO, THEN EITHER THE PAD IS CORRUPT, OR THERE IS A
            # SEVERE BUG IN THIS PROGRAM.
            $OutputChar = $InputChar;
            ++$FeedCount;
            warn("WARNING: Can't find ordinal ",$Ord," in pad row; ");
            warn("outputing raw input character.\n");
            warn("WARNING: Your pad may be corrupt.\n");
         } # end if
      } # end else if input character IS in standard character set

      # Push $OutputChar onto @OutputChars.
      push @OutputChars, $OutputChar;

      # Increment $CharCount here to indicate 1 more character has been
      # appended to @OutputChars. Since $CharIndex is never reset, and is
      # incremented ONLY here, it is literally "character count within entire
      # input text".
      ++$CharCount;
   } # end CHAR_LOOP

   # Form and print the output string from the output array, using print
   # rather than say, because line-breaks are just fed straight-through:
   print join '', @OutputChars;

   # Print stats to stderr:
   warn "Processed ",$CharCount," characters.\n";
   warn "Encrypted ",$CrypCount," characters.\n";
   warn "Verbatim  ",$FeedCount," characters.\n";

   # We're done, so end program:
   exit;
} # end main()


sub print_help_msg
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "Rot48", an unbreakable cipher by Robbie Hatley.

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ARGUMENTS, INPUT, AND OUTPUT:

   Rot48 takes one or two arguments.

   The first  argument ($ARGV[0]) must be the path to a pad file.
   (See "NOTES" and "PADS" sections below for more info on pad files.)

   The second argument ($ARGV[1]), if present, must be the path to a key file.
   (See "NOTES" and "KEYS" sections below for more info on key files.)

   Input  of material to be encoded or decoded is from stdin.

   Output of encoded or decoded material is to stdout.

   Material to be encoded should be ASCII text only. (To encode non-ASCII
   material, use my "Rot128" cipher instead.) Ideally, don't use any
   characters other than the 94 glyphical characters on a standard keyboard,
   plus space ('\x20') and horizontal tab ('\x09'). (Any bytes other than those
   96 will be passed-through unencoded.)

   The ciphertexts produced by this program will be ASCII text, but will be
   unreadible gibberish. Even the word lengths won't be the same, because
   rot48 treats spaces and tabs just like any other characters and encodes
   them to other characters. So there will be very few spaces and very-long
   gibberish "words".

   Also note that because this program is "invertible", running encoded material
   through this program a second time with the same pad and key will decode it
   back to its original form.

   If you keep the total number of characters in the input message less than or
   equal to the number of rows in the pad, this cypher becomes a variant of a
   "one-time pad" and is completely unbreakable, becaude each input character gets
   its own pad line.

   Note that including characters in your plain-text which are not in the
   96-character set used by this program weakens the security of this
   cipher, so it's best to keep such characters to a minimum. It's best to
   not use line breaks at all, or only use them to end paragraphs, and use
   your text editor's "word wrap" setting to read plain and cipher texts which
   use long paragraphs.

   Typical usage:
   rot48.pl 'pad.txt' 'key.txt' < plain.txt > cipher.txt

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   NOTES ON THE ROT48 CIPHER:

   The Rot48 cipher uses a "pad" of randomly-permuted arrays the 96-character
   character set consisting of the 94 glyphical characters on a standard
   101-key or 104-key keyboard, plus space ('\x20') and horizontal tab ('\x09').
   I'll call this character set "CHARSET" for the remainder of this document.
   In Perl lingo, CHARSET is:
   our @Charset = map chr, (9, 32..126);

   Each random permutation of CHARSET can be thought of as being a circular array,
   with the end attached to the beginning.  Since there are 96 elements, one
   48-position rotation through this circular array will take us to the far side,
   and another will take us back to where we started. Hence Rot48 is "invertible".

   Rot48 works by comparing each incoming character to one such array. If the
   character is found in the array, the character 48 positions around the circle
   (ie, the diametracally opposite character) is output; otherwise, the incoming
   character is output unchanged. Hence control characters, white-space
   characters other than space and tab, and non-ASCII characters will not be
   encrypted. Hence it is advisible to use almost entirely characters from CHARSET
   in plaintexts to be encrypted to avoid giving an interloper too many clues
   about the structure of the text.

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
   to any of (96!)^500 possible plaintexts, and without the pad which was used to
   encrypt the original plaintext, there is no way of determining which of those
   (96!)^500 plaintexts was intended. (In case you're wondering, (96!)^500 is
   about (10^150)^500, or about 10^75000, or a 1 followed by 75000 zeros (about
   23 printed pages filled with all 0s).)

   A Rot48 pad differs from a one-time pad in that each 96-character row of the
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
