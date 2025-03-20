#!/usr/bin/env perl
# This is a 78-character-wide ASCII-encoded Perl-source-code text file.
# =======|=========|=========|=========|=========|=========|=========|========
##############################################################################
# "oz2ml.pl"
# Translates oz to ml.
# Author: Robbie Hatley
# Edit history:
# Mon Mar 29, 2021:
#    Wrote it.
# Sat Nov 20, 2021:
#    Refreshed shebang, colophon, titlecard, and boilerplate;
#    using "common::sense" and "Sys::Binmode".
# Mon Mar 03, 2025:
#    Converted from Unicode to ASCII; reduced width from 120 to 78; got rid of
#    "common::sense" and "Sys::Binmode"; got rid of minimum version.
##############################################################################
print($_ * 29.5735295625, "\n") for @ARGV;
