#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# inc-test.pl
# Tests existence and directory-ness of all @INC entries.
#
# Written by Robbie Hatley, date unknown.
#
# Edit history:
#    ??? ??? ??, ????: Wrote it.
#    Thu Nov 25, 2021: Refreshed shebang, colophon, titlecard, and boilerplate. Refactored format of output.
########################################################################################################################

use v5.32;
use common::sense;

use RH::Dir;

for my $entry (@INC)
{
   print("\"$entry\"");
   print( ( -e e $entry ) ? " exists and " : " doesn't exist and "         ) ;
   print( ( -d e $entry ) ? "is a directory.\n" : "isn't a directory.\n" ) ;
}
