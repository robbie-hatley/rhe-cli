#!/usr/bin/env perl

##############################################################################################################
# double-case.pl
# Foldcases, sorts, and dedups the lines of a file, then replaces each unique line with the fold-cased
# version followed by the ucfirst-cased version. This program is very useful for processing Firefox's
# dictionaries, which need both the fold-cased and the ucfirst-cased version of each word.
# Written by Robbie Hatley.
# Edit history:
#   Sat Jun 27, 2026: Wrote it.
#   Thu Sep 10, 2026: Updated.
##############################################################################################################

use utf8::all;
use Cwd::utf8;
use List::Util qw( uniq );

# ======= VARIABLES: =========================================================================================

# ------- Local variables: -----------------------------------------------------------------------------------

# Settings:     Default:      Meaning of setting:
my @Opts      = ()        ; # Options.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv;
sub help;

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Process @ARGV and set settings:
   argv;

   # Fold-case <>, sort it, dedup it:
   my @unique = uniq sort {$a cmp $b} map {fc $_} <>;

   # For each unique fold-cased string in lexical order,
   # first print the fold-cased verion,
   # then  print the ucfirst-cased version:
   for my $line (@unique) {
      print         $line;
      print ucfirst $line;
   }

   # Exit program, returning success code 0 to caller:
   exit;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV:
sub argv {
   # Pull all options OUT of @ARGV and put them in @Opts instead:
   for ( my $i = 0 ; $i <= $#ARGV ; ++$i ) {
      # If current item is end-of-options marker, remove it from @ARGV and consider all remaining contents
      # of @ARGV to be "arguments" (file paths) rather than "options":
      if ( '--' eq $ARGV[$i] ) {
         splice @ARGV, $i, 1;
         last;
      }
      # If current item starts with '-', consider it to be an "option", remove it from @ARGV, push it to
      # @Opts, and decrement $i to compensate for the "++$i" above (because a not-yet-processed item has been
      # shifted leftward into position $i):
      if ( $ARGV[0] =~ m/^-/ ) {
         push @Opts, splice @ARGV, $i, 1;
         --$i;
      }
   }

   # @ARGV now contains NO options. If any items remain, they will be construed by the (<>) operator as being
   # files to be input, concatenated, numbered, and output to STDOUT.

   # Now, let's process our options:
   for (@Opts) {
      /^-h$/ || /^--help$/ and help and exit;
   }

   # Finally, return success code 1 to caller:
   return 1;
}

# Print help:
sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "double-case.pl". This program is a filter which foldcases, sorts,
   and dedups the lines of its input, the replaces each unique line with the
   lower-cased version followed by the first-cased version. This program is useful
   for processing personal dictionaries, because some programs (e.g., Firefox)
   need both the lower-cased and the first-cased versions of each word.

   -------------------------------------------------------------------------------
   Command lines:

   double-case.pl -h | --help        (to get help)
   double-case.pl in.txt > out.txt   (to double-case a dictionary)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:        Meaning:
   -h or --help   Print this help and exit.

   To mandate that all further arguments are not to be construed as options,
   use a "--" end-of-options indicator.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   All non-option arguments will be considered to be paths to files and will be
   input, concatenated, sorted, deduped, double-cased, and output, in the order
   received.


   Happy case doubling!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
