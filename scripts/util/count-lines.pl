#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# count-lines.pl
# Written by Robbie Hatley on Sat Feb 13, 2021.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Thu Aug 15, 2024: Narrowed from 120 to 110, "use v5.36", -C63, and removed unnecessary "use" statements.
# Tue Mar 04, 2025: Reduced min ver from "5.36" to "5.16".
##############################################################################################################

use v5.16;
use utf8;
my $i = 0;
map {++$i} <>;
say "$i"
