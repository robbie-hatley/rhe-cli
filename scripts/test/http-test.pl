#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# http-test.pl
# This program states whether each line of its input contains a HTTP type URI.#
#
# Usage is as follows:
# echo 'manually typed text' | http-test.pl
# http-test.pl filename
# http-test.pl < filename
#
# Edit history:
#    Sat May 25, 2019:
#       Wrote it, based on "http-regex-test.pl".
#    Tue Nov 09, 2021:
#       Refreshed colophon, title card, and boilerplate.
########################################################################################################################

use v5.32;
use utf8;
use Sys::Binmode;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

use Regexp::Common qw /URI/;

if ((defined $ARGV[0])&&('-h' eq $ARGV[0] || '--help' eq $ARGV[0]))
{
   Help();
   exit 0;
}

say 'HTTP regex from module "Regexp::Common":';
say qr{$RE{URI}{HTTP}};
say '';

while (<>)
{
   /$RE{URI}{HTTP}/ and say "Contains an HTTP URI." or say "No HTTP URI here!";
}

exit 0;

sub Help
{
   say 'This program states whether each line of its input contains';
   say 'a HTTP type URI. Usage is as follows:';
   say 'echo \'manually typed text\' | http-test.pl';
   say 'http-test.pl filename';
   say 'http-test.pl < filename';
   return 1;
}
