#!/usr/bin/env perl
# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|
##############################################################################################################
# extract-image-paths.pl
# Outputs those input lines which end with a cluster of non-space characters, followed by a dot, followed by
# an image file-name extension (m/bmp|gif|jfif|jpe?g|jp2|png|tiff?|webp/i).
# Written by Robbie Hatley.
# Edit history:
# Thu Nov 20, 2025: Wrote it.
##############################################################################################################
use utf8::all;
while (<>) {
   s/^\N{BOM}//; s/^\s+//; s/\s+$//;
   next if $_ !~ m/.+\.(?:bmp|gif|jfif|jp2|jpe?g|png|svg|tiff?|webp)$/i;
   print $_ . "\n";
}
