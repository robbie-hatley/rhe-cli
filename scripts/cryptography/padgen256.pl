#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# padgen256.pl
# Generates one-time pads for my "rot128.pl" script.
# See the print_help_msg subroutine for description and instructions.
# Edit history:
#    Sun May 17, 2015: Wrote it.
#    Fri Jul 17, 2015: Minor cleanup (comments, etc).
#    Sun Apr 17, 2016: Minor corrections to comments and POD.
#    Wed Jan 10, 2018: use v5.026, and improved comments.
#    Sat May 19, 2018: use v5.20, dramatically improved instructions, and
#                      moved instructions to print_help_msg().
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

sub print_help_msg;

# main:
{
   if (@ARGV == 1 && ($ARGV[0] eq '-h' || $ARGV[0] eq '--help'))
   {
      print_help_msg();
      exit;
   }

   if (@ARGV != 1 || $ARGV[0] < 10 || $ARGV[0] > 2000000000)
   {
      warn("Error: padgen256.pl takes 1 argument, which must be an integer\n".
           "in the 10-2000000000 range.\n");
      print_help_msg();
      exit;
   }

   my @Charset = map chr, (0..255);
   for (1..$ARGV[0])
   {
      my @TempCharset = @Charset;
      my @PermCharset;
      while (@TempCharset)
      {
         push(@PermCharset, splice(@TempCharset, rand(@TempCharset), 1));
      }
      print((join '', @PermCharset));
   }
   exit;
}


sub print_help_msg
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "PadGen256", a pad generator for "Rot128", which is
   an unbreakable cipher by Robbie Hatley.

   PadGen256 writes to standard output a set of permutations of the
   256-character character set consisting of all possible 1-byte characters.
   The permutations are written end-to-end with no line-break characters
   between permutations or at the end. Therefore the total number of bytes
   written will always be 256 times the number of permutations written.

   PadGen256 takes exactly 1 argument, which must be an integer in the range
   10-2000000000, indicating the number of permutations to write. If the number
   of arguments is not 1, or if the argument is not an integer in the
   10-2000000000 range, PadGen96 will abort.

   The purpose of this program is to generate one-time pads for my Rot128
   program, which is an invertible, unbreakable cipher. These one-time pads
   are not to be confused with "keys", which in the context of rot128 are
   the integers 0 through n-1 (for some n) separated by commas. If a pad has,
   say, 1000 lines (generated by "padgen256.pl 1000 > pad256-1000_73.txt"
   it should be used in conjunction with an order-1000 key, generated by
   one of these programs:
   perm-keygen.pl 1000 > key1000-73.txt
   rand-keygen.pl 1000 > key1000-73.txt
   That would be suitable for use with a message of up to 1000 characters if
   total unbreakability is needed. (Longer messages could be encoded, but the
   unbreakability would then drop below 100%.) Each pad should use its own key
   to maintain complete unbreakability.

   For further information on Rot128 and its pads and keys, type:
   rot128.pl --help

   Cheers,
   Robbie Hatley,
   Programmer
   END_OF_HELP
   return 1;
}
