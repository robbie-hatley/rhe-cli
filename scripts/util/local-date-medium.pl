#!/usr/bin/env perl

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# local-date-medium.pl
# Prints current local date in "Mon Jul 04, 2016" format.
# Written by Robbie Hatley.
#
# Edit history:
# Tue Apr 19, 2016: Wrote "date.pl", which seems to be the basis of all my time & date scripts.
# Wed Sep 16, 2020: Wrote this version. Now using strftime.
# Thu Feb 04, 2021: Fixed "no newline at end" bug and cleaned-up comments and formatting.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Mon Mar 03, 2025: Reverted from Unicode to ASCII. Got rid of "use 5.32".
#                   Got rid of "common::sense" and "Sys::Binmode". Reduced width from 120 to 110.
##############################################################################################################

use POSIX 'strftime';

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
print POSIX::strftime(  "%a %b %d, %Y\n",$sec,$min,$hour,$mday,$mon,$year);
