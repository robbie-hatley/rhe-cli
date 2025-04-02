#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# print-url-lines.pl
# Prints those lines of a file which contain "http:".
#
# Written by Robbie Hatley on Saturday January 10, 2015.
#
# Edit history:
# Sat Jan 10, 2015: Wrote it.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Sun Apr 17, 2016: Changed regex to "/https?:/".
# Tue Nov 09, 2021: Refreshed shebang, colophon, and boilerplate.
# Wed Dec 08, 2021: Reformatted titlecard.
# Sun Aug 04, 2024: Reduced width from 120 to 110. Upgraded from "v5.32" to "v5.36".
#                   Got rid of "use common::sense". Got rid of "use Sys::Binmode". Added "use utf8".
# Tue Apr 01, 2025: Reduced min ver "5.36" -> "5.00". Renamed from "print-urls.pl" to "print-url-lines.pl".
##############################################################################################################

use v5.00;
use utf8;

while (<>) {
   print if /https?:/;
}
