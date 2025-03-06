#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# delta.pl
# Presents "added" lines which are in a second file but not in a first,
# and "subtracted" lines which are in a first file but not in a second.
#
# Edit history:
# Sat May 07, 2016: Wrote it.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate;
#                   now using "common::sense" and "Sys::Binmode".
# Thu Aug 15, 2024: Narrowed from 120 to 110, upgraded from "v5.32" to "v5.36,
#                   and removed unnecessary "use" statements.
# Wed Feb 26, 2025: Trimmed one horizontal divider.
# Tue Mar 04, 2025: Got rid of unnecessary prototypes and sigs.
##############################################################################################################

use v5.36;
use utf8;
use Encode;

# ======= SUBROUTINE PRE-DECLARATIONS ========================================================================

sub argv                     ;
sub in_array :prototype($\@) ;
sub error                    ;
sub help                     ;

# ======= GLOBAL VARIABLES ===================================================================================

our @Arguments;  # CL args not starting with '-'
our @Options;    # CL args starting with '-'

# ======= MAIN BODY OF PROGRAM ===============================================================================

# main
{
   argv;

   my $fh1;
   open($fh1, '<', encode_utf8 $Arguments[0]) or die "Can't open first file.\n$!\n";
   my @First = <$fh1>; # Don't decode here; that's handled by the "-C63" in the shebang.
   close($fh1);

   my $fh2;
   open($fh2, '<', encode_utf8 $Arguments[1]) or die "Can't open second file.\n$!\n";
   my @Second = <$fh2>; # Don't decode here; that's handled by the "-C63" in the shebang.
   close($fh2);

   my @Added;
   foreach (@Second) {
      if (!in_array($_, @First)) {
         push(@Added, $_);
      }
   }

   my @Subtracted;
   foreach (@First) {
      if (!in_array($_, @Second)) {
         push(@Subtracted, $_);
      }
   }

   say("\n\nAdded lines:");
   print @Added;

   say("\n\nSubtracted lines:");
   print @Subtracted;

   # We be done, so scram:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS =============================================================================

sub argv {
   foreach (@ARGV) {
      if (/^-[\pL\pN]{1}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/) {
         push(@Options, $_);
      }
      else {
         push(@Arguments, $_);
      }
   }

   # If user wants help, just print help and bail:
   foreach (@Options) {
      if ('-h' eq $_ || '--help' eq $_) {help; exit(777);}
   }

   # If number of arguments is out of range, bail:
   my $NA = scalar(@Arguments);
   if ( 2 != $NA ) {error($NA); help; exit(666)}

   return 1;
} # end argv

sub in_array :prototype($\@) ($Element, $ArrayRef) {
   foreach my $item (@$ArrayRef) {
      if ($item eq $Element) {
         return 1;
      }
   }
   return 0;
} # end in_array

sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but delta.pl takes exactly 2 arguments,
   which must be paths to text files. Help follows:
   END_OF_ERROR
   return 1;
} # end error

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "delta.pl". This program presents "added" lines which are in
   a second file but not in a first, and "subtracted" lines which are in
   a first file but not in a second.

   Command lines:
   delta.pl [-h|--help]       (to get this help)
   delta.pl file1 file2       (to present differences between 2 files)

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.

   This program takes exactly two arguments, which must be paths of existing
   text files. For example:

   delta.pl 'MyScript-V3.71.pl' 'MyScript-V3.72.pl'

   This program will then present you with two lists:
   A list of   "Added"    lines which are in file2 but not file1.
   A list of "Subtracted" lines which are in file1 but not file2.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end help
