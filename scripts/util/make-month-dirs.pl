#!/usr/bin/env perl
# This is a 85-character-wide ASCII Perl source-code text file with Unix line breaks.
#####################################################################################
# make-month-dirs.pl                                                                #
# Creates subdirectories "01" through "12" in current directory, for "month" use.   #
# Written at an unknown time by Robbie Hatley.                                      #
# Edit history:                                                                     #
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate;        #
#                   using "common::sense" and "Sys::Binmode".                       #
# Wed Sep 06, 2023: Upgraded from "v5.23" to "v5.36". Got rid of "common::sense"    #
#                   (antiquated). Downgraded encoding to ASCII. Width now 85.       #
# Sat Mar 15, 2025: Updated these comments; updated shebang.                        #
#####################################################################################
for (1..12) {
   my $month = sprintf "%02d", $_ ;
   mkdir "$month";
}
