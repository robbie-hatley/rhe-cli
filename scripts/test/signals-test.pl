#!/usr/bin/env -S perl -CSDA

# This is an 78-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|========

##############################################################################
# /rhe/scripts/test/signals-test.pl
##############################################################################

use v5.32;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;
no warnings 'uninitialized';

foreach (keys %SIG)
{
   say "SIG{$_} = $SIG{$_}";
}
