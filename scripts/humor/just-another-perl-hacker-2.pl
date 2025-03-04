#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

# "big-int-2.pl"

use utf8;
use bigint;

# my $n = 71423350343770280161397026330337371139054411854220053437565440;
# my $n = 0x2c72656b636168206c72655020726568746f6e61207473754a00
#            , r e k c a h   l r e P   r e h t o n a   t s u J
# Hmmm... those last two digits can be elided because they're a nul character:
# my $n = 0x2c72656b636168206c72655020726568746f6e61207473754a;
#            , r e k c a h   l r e P   r e h t o n a   t s u J
# Then convert that back to decimal:
my $n=278997462280352656880457134102880356011931296305547083740490;
my $m=-8;$_=$n&(0xff)<<$m,$_>>=$m,print chr $_ while(($m+=8)<=192);
