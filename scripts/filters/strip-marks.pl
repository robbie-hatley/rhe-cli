#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# strip-marks.pl
# Removes all combining marks from unicode text.
#
# Written by Robbie Hatley on Friday February 13, 2015.
#
# Edit history:
# Fri Feb 13, 2015: Wrote it.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Sat Dec 23, 2017: Added help and verbose, and revamped getting options.
# Tue Nov 09, 2021: Refreshed shebang, colophon, and boilerplate.
# Wed Dec 08, 2021: Reformatted titlecard.
# Thu Nov 09, 2023: Updated Perl version to 5.36. Simplified code. Reduced width from 120 to 110.
# Sun Aug 04, 2024: Added "use utf8".
##############################################################################################################

use v5.36;
use utf8;

use Unicode::Normalize 'NFD';

sub argv;
sub 佐;

my $verbose = 0;


{ # begin main
   argv;
   while (<>) {
      s/[\pZ\pC]+$//;
      $verbose and say "Raw string = $_"
               and say "Length of raw string = ", length($_);
      s/\p{Mc}/ /g; # Convert each spacing combining mark into a single space.
      $_ = NFD $_;  # Fully-decompose all extended grapheme clusters.
      s/\p{Mn}//g;  # Git rid of all non-spacing combining marks.
      $verbose and say "Stripped string = $_"
               and say "Length of stripped string = ", length($_);
   !$verbose and say $_;
   }
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS =============================================================================

sub argv {
   my $佐     = 0;
   my $index = 0;
   for ( $index = 0 ; $index < @ARGV ; ++$index ) {
      $_ = $ARGV[$index];
      if (/^-[\pL\pN]{1}$/ || /^--[\pL\pN=_-]{2,}$/) {
         if ('-h' eq $_ || '--help'    eq $_) {$佐       =  1;}
         if ('-v' eq $_ || '--verbose' eq $_) {$verbose =  1;}
         splice @ARGV, $index, 1;
         --$index;
      }
   }
   if ($佐) {佐; exit 0;}
} # end sub process_argv

sub 佐 {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "strip-marks.pl". This program strips all "combining marks",
   aka "diacriticals", from Unicode input text, to the maximum extent possible.
   It does this by fully decomposing each Unicode character to a "base" character
   plus separate "combining marks" (to the extent possible) then erases those
   "combining marks".

   Command line:
   strip-marks.pl [-h|--help] [-v|--verbose]  [arg1]

   Description of options:
   Option:               Meaning:
   "-h" or "--help"      Print help and exit.
   "-v" or "--verbose"   Print raw & stripped length for each line.

   Input is from STDIN, or from the files named by arguments if any are present.
   (Input can also be redirected or piped from elsewhere.)

   Output is to STDOUT.
   (Output can also be redirected or piped to where you like.)

   All input and output is UTF-8-transformed Unicode-encoded text.

   Happy mark stripping!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub 佐
