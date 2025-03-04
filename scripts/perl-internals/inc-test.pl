#!/usr/bin/env perl

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# inc-test.pl
# Tests existence and directory-ness of all @INC entries.
#
# Written by Robbie Hatley, date unknown.
#
# Edit history:
#    Thu Nov 25, 2021: Refreshed shebang, colophon, titlecard, and boilerplate. Refactored format of output.
#    Mon Mar 03, 2025: Got rid of "v5.36", "RH::Dir", "common::sense". Converted from Unicode to ASCII.
##############################################################################################################

use Encode;

for my $entry (@INC) {
   print("\"$entry\"");
   print( ( -e encode_utf8($entry) ) ? " exists and " : " doesn't exist and "       ) ;
   print( ( -d encode_utf8($entry) ) ? "is a directory.\n" : "isn't a directory.\n" ) ;
}
