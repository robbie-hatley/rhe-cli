#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# /rhe/scripts/util/signals.pl
# Prints list of signals.
# Edit history:
#    December of 2014?- Wrote it.
#    Fri Jul 17, 2015 - Wrote these comments and dramatically simplified.
#    Mon Dec 25, 2017 - Now prints keys only.
########################################################################################################################

use v5.32;
use utf8;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

no warnings qw ( uninitialized );

printf("\nHash %%main::SIG contains %d entries:\n\n", scalar keys %main::SIG);
#map {print "$_ => $SIG{$_}\n"} sort keys %main::SIG;
$, = ' ';
print sort keys %main::SIG;
