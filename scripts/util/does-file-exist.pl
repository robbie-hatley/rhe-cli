#!/usr/bin/env perl

# This is a 110-character-wide ASCII Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# does-file-exist.pl
# Tells whether a file exists at each of the paths given by @ARGV.
#
# Edit history:
# Tue Jun 09, 2015: Wrote it.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; now using "common::sense" and
#                   "Sys::Binmode".
# Sat Aug 03, 2024: Reduced width from 120 to 110 (for github purposes). Upgraded from "v5.32" to "v5.36".
#                   Got rid of "common::sense". Shortened sub names. Added prototypes. Added "use utf8".
#                   Allowed checking of multiple paths at once (because, why not?).
# Thu Aug 15, 2024: -C63; got rid of "Sys::Binmode".
# Tue Mar 04, 2025: Got rid of all prototypes and empty sigs.
# Thu Mar 06, 2025: Dramatically simplified. Got rid of all subs. Reduced min ver from "5.36" to "5.00".
#                   Also, got rid of "-C63", "use utf8", and "use Encode". Now "feeding through" UTF-8
#                   file and directory names, NOT decoded to Unicode codepoints, so no need to encode them
#                   when using file-test operators, print statements, etc. We only need decoding & encoding
#                   when using Unicode semantics, and this program doesn't do that.
##############################################################################################################

use v5.00;

# If user wants help, give help and exit:
for (@ARGV) {
   if (/^-h$|^--help$/) {
      print STDERR ((<<'      END_OF_HELP') =~ s/^      //gmr);
      Welcome to "does-file-exist.pl", Robbie Hatley's nifty program for determining
      whether files exists at the paths given as command-line arguments.

      Note: I'm using the word "file" in the broadest-possible Linux interpretation,
      to include regular data files, links, directories, pipes, sockets, devices,
      etc. In Linux, every item in a storage medium (and some items that AREN'T in a
      storage medium) is a "file". This program can determine the existence
      (or non-existence) of all of them.

      Command lines:
      does-file-exist.pl [-h|--help]           (to get help)
      does-file-exist.pl path1 path2 path3...  (to check file existence)

      Cheers,
      Robbie Hatley,
      programmer.
      END_OF_HELP
      exit 777;
   }
}

# Determine and print the existence or nonexistence of files at paths in @ARGV:
for my $path (@ARGV) {
   -e $path
   and print "File exists:  \"$path\"\n"
   or  print "No such file: \"$path\"\n";
}
