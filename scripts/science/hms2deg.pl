#!/usr/bin/env perl

# This is a 110-character-wide ASCII Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# hms-to-deg.pl
# Converts time-zone difference (in hours, minutes, and seconds) to longitude difference (in degrees).
# Written by Robbie Hatley.
# Edit history:
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Mon Mar 03, 2025: Got rid of "common::sense" and "Sys::Binmode". Got rid of minimum version.
# Thu Mar 20, 2025: Converted to ASCII.
##############################################################################################################

print 15*$ARGV[0] + $ARGV[1]/4 + $ARGV[2]/240, "\n";
