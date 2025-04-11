#!/usr/bin/env perl

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# bubble-babble.pl
# Encrypts text into "Bubble Babble" format.
#
# Edit history:
# Mon Feb 24, 2020: Wrote it.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Fri Aug 04, 2023: Updated from "v5.32" to "v5.36". Got rid of "common::sense". Moved to "filters".
# Fri Aug 02, 2024: Got rid of "use strict", "use warnings", "use Sys::Binmode".
# Sat Aug 03, 2024: Reduced width from 120 to 110.
# Fri Apr 11, 2025: Nixed "use v5.36". Now using "utf8::all". Simplified shebang to "#!/usr/bin/env -perl".
##############################################################################################################
use utf8::all;
use Digest::BubbleBabble 'bubblebabble';
while(<>) {
   chomp;
   print bubblebabble(Digest=>$_), "\n";
}
