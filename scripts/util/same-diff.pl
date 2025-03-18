#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# same-diff.pl
# Given a reference string $S1 and a test string $S2, this program will find the largest substring of $S2 at
# each of its indices from 0 to $#S2 which have a match within $S1. It will then paste-together all such
# matching substrings of $S2 and return it as "same = ", and will also paste-together all parts of $S2 which
# did NOT match $S1 and return it as "diff = ". Hence the name, "same-diff.pl".
#
# Written by Robbie Hatley.
#
# Edit history:
# Wed Mar 09, 2022: Wrote it.
# Wed Aug 09, 2023: Upgraded from "v5.32" to "v5.36". Got rid of "common::sense" (antiquated). Reduced width
#                   from 120 to 110. Added strict, warnings, etc, to boilerplate.
# Thu Aug 15, 2024: -C63; got rid of unnecessary "use" statements; fixed regex meta bug with "\Q".
# Sun Mar 16, 2025: Changed bracing to C-style. Nixed extraneous "help" and "exit" lines in error().
#                   Improved description above, which was very vague.
##############################################################################################################

use v5.36;
use utf8;

# ======= VARIABLES: =========================================================================================

# Settings:          Meaning of setting:          Range:    Meaning of default:
my $Db     = 0   ; # Print diagnostics?           bool      Don't print diagnostics.
my $Help   = 0   ; # Print help and exit?         bool      Don't print help and exit.
my $refe   = ''  ; # Reference string.            string    Empty string.
my $test   = ''  ; # Test string.                 string    Empty string.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv  ; # Process @ARGV.
sub error ; # Print error message.
sub help  ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   argv;
   $Help and help and exit(666);
   say STDERR "refe = $refe";
   say STDERR "test = $test";
   my $tsz       = length($test);
   my $matches   = '';
   my $same      = '';
   my $diff      = '';
   my $substring = '';;
   for ( my $i = 0 ; $i < $tsz ; ++$i ) {
      for ( my $j = $tsz - $i ; $j > 0 ; --$j ) {
         $substring = substr($test, $i, $j);
         if ($Db) {say "\$substring = $substring";}
         $matches = ($refe =~ m/\Q$substring/);
         if ($matches) {
            say "Match found at index $i: $&";
            $same .= substr($test, $i, $j);
            $i += $j; # Advance $i by $j
            --$i; # But then, back-up $i by 1 to compensate for the "++$i" in the outer for loop.
            last;
         }
      }
      if (!$matches) {
         say "No match found at index $i.";
         $diff .= substr($test, $i, 1)
      }
   }
   say "same = $same";
   say "diff = $diff";
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV :
sub argv {
   # Get options and arguments:
   my @opts = ();
   my @args = ();
   my $end_of_options = 0;
   for ( @ARGV ) {
      /^--$/ and $end_of_options = 1 and next;
      !$end_of_options && /^-\pL+$|^--\pL+$/ and push @opts, $_ or push @args, $_;
   }

   # Process options:
   for ( @opts ) {
      /^-\pL*e|^--debug$/ and $Db   = 1;
      /^-\pL*h|^--help$/  and $Help = 1;
   }

   # Count args:
   my $NA = scalar @args;

   # If number of arguments is not 2 and we're not getting help, abort execution:
   if ( 2 != $NA && !$Help ) {
      error($NA); # Print error message.
      help;       # Provide help.
      exit 666;   # Return The Number Of The Beast.
   }

   # Else, set reference and test strings:
   if ( $NA > 0 ) {$refe = $args[0];} # Set $refe
   if ( $NA > 1 ) {$test = $args[1];} # Set $test

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Handle errors:
sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes exactly 2 arguments.
   Help follows.
   END_OF_ERROR
} # end sub error

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "same-diff.pl". Given a reference string S1 and a test string S2,
   this program will find the largest substring of S2 at each of its indices
   from first to last which have a match within S1. It will then concatenate all
   such matching substrings of S2 and return it as "same = ", and will also
   concatenate all left-over characters of S2 which did NOT match S1 and return
   that string as "diff = ". Hence the name, "same-diff.pl".

   Command lines:
   same-diff.pl  -h              (to print this help and exit)
   same-diff.pl [-e] refe test   (to search for substrings of test in refe)

   Description of options:
   Option:                   Meaning:
   "-h" or "--help"          Print help and exit.
   "-e" or "--debug"         Print diagnostic info.

   All options not listed above are ignored.

   Description of arguments:
   This program takes exactly 2 arguments. The first must be a reference string
   to look for patterns in, and the second must be a test string with patterns
   to search for in the reference string. A number of arguments other than 2
   will cause the program to abort, unless just getting help.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
