#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# tsv2url.pl
# Converts a youtube-playlist tsv file into a urls csv file.
# Written by Robbie Hatley.
# Edit history:
# Sat Aug 02, 2025: Wrote it.
##############################################################################################################

use v5.36;
use utf8::all;

while (<>) {
   my $num = s#^(.{11})\\t.*$#https://www.youtube.com/watch?v=${1}#;
   print;
}
