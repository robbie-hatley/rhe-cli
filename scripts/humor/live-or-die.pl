#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# live-or-die.pl
########################################################################################################################

use v5.32;
use utf8;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

warn "If you party, you'll catch COVID-19 and die.\n";
warn "So what's it gonna be, punk?\n";
warn "Type \"party\" to party, or anything else to not party.\n";
our $response = <STDIN>;
$response =~ m/party/i
and die "You have died. Your next of kin will be notified.\n"
or  say "Congratulations, you live! Stay home, write code, and have fun!";
