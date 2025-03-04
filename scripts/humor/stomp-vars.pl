#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# stomp-vars.pl
# Destroy symbol table.
# Note: As of 2021-11-11, this fails with "Modification of a read-only value attempted at stomp-vars.pl line 23",
# so I think the ability to stomp on the symbol table has been patched.
########################################################################################################################

use v5.32;
use utf8;
no strict;
no warnings;

no warnings 'numeric';

foreach my $symname (sort keys %main::) {
   ${$main::{$symname}} = "asdf";
   say "\${\$main::{$symname}} = ${$main::{$symname}}";
}
