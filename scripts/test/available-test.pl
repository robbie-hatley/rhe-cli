#!/usr/bin/env -S perl -CSDA

# This is an 120-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# /rhe/scripts/test/available-test.pl
# Tests subs "find_available_name" and "clone_file" in module "RH::Dir".
# Written by Robbie Hatley, 2020-03-23.
########################################################################################################################

use v5.32;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;

use RH::Util;
use RH::Dir;

for (1..10010)
{
   clone_file
   (
      'test-file.txt',
      '/D/test-range/clone-test-dest'
   );
}
