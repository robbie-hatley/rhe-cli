#!/usr/bin/env -S perl -CSDA

# This is an 120-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# /rhe/scripts/test/beep-test.pl
# Tests ability to access beeper or send sounds to speaker.
# Edit history:
#    Fri Mar 13, 2020: Wrote first draft.
########################################################################################################################

use v5.32;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;

use Win32::API;

my $function =
   Win32::API::More->new
   (
      'kernel32.dll',
      'BOOL Beep(DWORD dwFreq, DWORD dwDuration);'
   );

$function->Call(1000,700);
$function->Call(1500,700);
$function->Call(1250,700);
$function->Call(1300,700);
$function->Call(1150,700);

say 'asdf';

