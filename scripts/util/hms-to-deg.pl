#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# hms-to-deg.pl
# Converts time-zone difference (in hours, minutes, and seconds) to longitude difference (in degrees).
#
# Edit history:
# Sat Nov 20, 2021:
#    Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and "Sys::Binmode".
# Mon Mar 03, 2025:
#    Got rid of "common::sense" and "Sys::Binmode". Got rid of minimum version.
##############################################################################################################

print 15*$ARGV[0] + $ARGV[1]/4 + $ARGV[2]/240, "\n";
