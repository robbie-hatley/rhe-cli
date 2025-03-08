#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# are-files-identical.pl
# Tells you whether two specified files are identical or different.
# Input is via command-line arguments.
# Output is to STDOUT.
# Edit history:
# Sat Jun 27, 2015: Wrote it.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Thu Oct 03, 2024: Got rid of Sys::Binmode and common::sense; added "use utf8".
# Thu Mar 06, 2025: Reduced width from 120 to 110. Simplified. Reduced min ver from "5.32" to "5.00".
#                   Renamed from "files-are-identical.pl" to "are-files-identical.pl".
##############################################################################################################

use v5.00;
use utf8;

use RH::Dir qw( e FilesAreIdentical );

sub argv ; # Process @ARGV.
sub help ; # Print help.

my $path1; # Path to first  file.
my $path2; # Path to second file.

{ # begin main
   argv;
   if (FilesAreIdentical($path1,$path2)) {print "Files are identical.\n"}
   else                                  {print "Files are different.\n"}
   exit 0;
} # end main

sub argv {
   # If user wants help, just print help and bail:
   /^-h$/ || /^--help$/ and help and exit 777 for @ARGV;

   # If number of arguments is not 2, bail:
   die "Error: are-files-identical.pl takes 2 arguments, which must be paths to\n".
       "two files to be compared. Use -h or --help option to get help.\n"
   if 2 != scalar(@ARGV);

   # Set $path1 and $path2:
   ($path1, $path2) = ($ARGV[0], $ARGV[1]);

   # Abort if first file does not exist:
   die "Error: First file does not exist.\n"  if !-e e $path1;

   # Abort if second file does not exist:
   die "Error: Second file does not exist.\n" if !-e e $path2;
}

sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "are-files-identical.pl". This program simply compares two files
   and says whether or not they have identical content. (Name, size, date, and
   attributes need not be the same for two files to be considered "identical";
   this program only compares contents.)

   Command line to get help:
   are-files-identical.pl [-h|--help]

   Command line to compare two files:
   are-files-identical.pl 'file1' 'file2'

   'file1' and 'file2' must be valid paths to two files to be compared.
   Enclosing both paths with 'single quotes' is highly recommended,
   because otherwise, if either path contains spaces or certain other characters,
   the shell may not properly pass the paths to the program.

   are-files-identical.pl   hi there 1.txt   hi there 2.txt   # FAILS
   are-files-identical.pl  'hi there 1.txt' 'hi there 2.txt'  # WORKS

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
}
