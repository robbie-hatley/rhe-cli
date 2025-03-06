#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
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
##############################################################################################################

use v5.36;
use utf8;
use Encode;

my @paths; # Paths of files to check for existence.

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "does-file-exist.pl", Robbie Hatley's nifty program for determining
   whether files exists at the paths given as command-line arguments.

   Note: I'm using the word "file" in the broadest-possible Linux interpretation,
   to include regular data files, links, directories, pipes, sockets, devices,
   etc. In Linux, every item in a storage medium (and some times that AREN'T in a
   storage medium) is a "file". This program can determine the existence
   (or non-existence) of all of them.

   Command lines:
   does-file-exist.pl [-h|--help]           (to get help)
   does-file-exist.pl path1 path2 path3...  (to check file existence)

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help

sub argv {
   # If user wants help, give help and exit:
   /^-h$|^--help$/ and help and exit 777 for @ARGV;

   # If we get to here, store all arguments in @paths:
   @paths = @ARGV;

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process @ARGV:
argv;

# Determine and print the existence or nonexistence of files at paths in @paths:
for my $path (@paths) {
   -e encode_utf8($path)
   and say "File exists:  \"$path\""
   or  say "No such file: \"$path\""
}
