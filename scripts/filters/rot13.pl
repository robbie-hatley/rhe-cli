#!/usr/bin/env perl
###############################################################################
# /rhe/scripts/util/rot13.pl
# Performs ROT13 obfuscation on text.
# Written by Robbie Hatley circa Friday July 4, 2014.
# Edit history:
# Fri Jul 04, 2014: Wrote it. (Date is a wild guess.)
# Fri Jul 17, 2015: Made minor improvements.
# Fri Feb 05, 2016: Cleaned up formatting.
# Tue Nov 09, 2021: Refreshed shebang, colophon, and boilerplate.
# Wed Dec 08, 2021: Reformatted titlecard.
# Sun Aug 04, 2024: Width 120->110. "v5.32"->"v5.36". Added "use utf8".
# Tue Apr 08, 2025: Reduced width from 110 to 79; converted to ASCII.
###############################################################################
while(<>) {
   tr/A-MN-Za-mn-z/N-ZA-Mn-za-m/;
   print;
}
