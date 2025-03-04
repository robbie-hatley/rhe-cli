#!/usr/bin/env -S perl -C63

# This is an 78-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|========

# "de-vowel.pl"

use utf8;

while (<>) {
   tr/aeiouAEIOU//d;
   print;
}
