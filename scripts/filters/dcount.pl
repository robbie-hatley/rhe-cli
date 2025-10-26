#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# dcount.pl
# Prints count of dreams (in a dream-log file in which each dream is prefaced by a line of 49 tildes).
#
# Edit history:
# Tue Oct 21, 2025: Wrote it.
##############################################################################################################

use v5.36;
use utf8::all;
my $dcount = 0;
while (<>) {
   chomp;
   ++$dcount if $_ eq '~'x49;
}
say $dcount;
