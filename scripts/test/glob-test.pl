#!/usr/bin/env -S perl -CSDA

# This is an 120-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

use v5.32;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;

use RH::Dir;

say for (glob_utf8('.* /sl/*.jpg'));
