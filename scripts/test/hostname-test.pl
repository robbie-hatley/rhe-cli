#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# hostname-test.pl
# Tests methods of finding current computer's network name.
#
# Edit history:
#    Thu Jan 21, 2021: Wrote it.
########################################################################################################################

use v5.32;
use strict;
use warnings;
use experimental 'switch';
use utf8;
use warnings FATAL => "utf8";

use Sys::Hostname;

my $host = hostname;
say "This computer's network name = \"$host\".";
