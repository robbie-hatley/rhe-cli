#!/usr/bin/env perl

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# utcshort.pl
# Prints current UTC time and date in "2021-02- 5 04:36:37 UTC" format.
# Written by Robbie Hatley.
#
# Edit history:
# Tue Apr 19, 2016: Wrote "date.pl", which seems to be the basis of all my time & date scripts.
# Wed Sep 16, 2020: Wrote this version. Now using strftime.
# Thu Feb 04, 2021: Fixed "no newline at end" bug and cleaned-up comments and formatting.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Wed Aug 09, 2023: Upgraded from "v5.32" to "v5.36". Got rid of "common::sense" (antiquated). Reduced width
#                   from 120 to 110. Added strict, warnings, etc, to boilerplate.
# Thu Oct 03, 2024: Got rid of "use Sys::Binmode".
# Mon Mar 03, 2025: Reverted from Unicode to ASCII. Got rid of "use 5.36".
##############################################################################################################

use POSIX 'strftime';

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime;
print POSIX::strftime("%Y-%m-%e %T UTC\n",$sec,$min,$hour,$mday,$mon,$year);
