#!/usr/bin/env perl
# This is a 78-character-wide ASCII-encoded Perl-source-code text file.
# =======|=========|=========|=========|=========|=========|=========|========
##############################################################################
# mm2in.pl
# Converts millimeters to inches.
# Author: Robbie Hatley.
# Edit history:
# Fri Apr 02, 2021:
#    Wrote it.
# Sat Nov 20, 2021:
#    Refreshed shebang, colophon, titlecard, and boilerplate;
#    using "common::sense" and "Sys::Binmode".
# Mon Mar 03, 2025:
#    Converted from Unicode to ASCII; reduced width from 120 to 78; got rid of
#    "common::sense" and "Sys::Binmode"; got rid of minimum version.
##############################################################################
print($_ / 25.4, "\n") for @ARGV;
