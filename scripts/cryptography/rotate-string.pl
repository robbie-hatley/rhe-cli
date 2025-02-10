#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# rotate-string.pl
# Prints string given by first argument, rotated by the number of characters given by second argument.
# Rotation is done by moving the given number of characters from the end to the beginning.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and "Sys::Binmode".
########################################################################################################################

use v5.32;
use common::sense;

use RH::Math;

sub Rotate ($$)
{
   my $InpStr = shift;
	my $RotAmt = shift;
   my $OutStr =
      substr($InpStr, length($InpStr)-$RotAmt, $RotAmt) .
      substr($InpStr, 0, length($InpStr)-$RotAmt);
   return $OutStr;
}

{ # begin main()
   die "Error.\n" if 2!=scalar(@ARGV) || !is_integer($ARGV[1]);
   say Rotate($ARGV[0], $ARGV[1]);
   exit 0;
} # end main()

