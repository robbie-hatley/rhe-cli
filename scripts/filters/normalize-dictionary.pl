#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# normalize-dictionaries.pl
# Removes all but the left-most word on each line of a file, lower-cases and sorts the first words, and prints
# the results, without altering the original file.
# Written by Robbie Hatley.
# Edit history:
# Wed Oct 14, 2026: Wrote it.
##############################################################################################################

use v5.40;
use utf8::all;

# Selected CPAN Modules which may be helpful:
use Unicode::Normalize;
use Unicode::Collate;

# ======= VARIABLES: =========================================================================================

my @Opts  = (); # Options.
my $Help  = 0 ; # Print help and exit?

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv;
sub help;

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Process @ARGV:
   argv;

   # If user requested help, print help and exit:
   if ($Help) {
      help;
      exit 0;
   }

   # Otherwise, print normalized version of input:
   my @raw = map {chomp;$_;} <>;
   my @stripped = map {s/^(\pL+)\s+.*$/lc $1/er} @raw;
   # ECHIDNA: Eventually, I need to replace "sort" below with Unicode normalization and collation.
   # The "sort" version works, but will screw-up characters using extended grapheme clusters.
   my @sorted = sort @stripped;
   say for @sorted;
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

   # Now, let's process our options and set settings accordingly:
   for (@Opts) {
      /^-h$/ || /^--help$/ and $Help = 1;
   }

   # Finally, return success code 1 to caller:
   return 1;
} # end sub argv

# Print help:
sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   This program removes all but the left-most word on each line of its input,
   lower-cases and sorts the first words, and prints the results, without altering
   the original file. Input is from the files listed on the command line, else
   from STDIN. Output is to STDOUT.

   -------------------------------------------------------------------------------
   Command lines:

   normalize-dictionary.pl -h | --help             (to print this help and exit)
   normalize-dictionary.pl [options] [Arguments]   (to normalize dictionaries)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.
         --           End of options (all further CL items are arguments).

   If you want to use arguments that begin with hyphens, use a "--" option first;
   that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above will be ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   Any arguments will be construed as being paths of files from which to take
   input.

   -------------------------------------------------------------------------------
   RAM WARNING:

   Because this script slurps its entire input into RAM all at once, and worse,
   makes 3 copies, it is very RAM intensive. If you are going to run this program
   on large files, I strongly recommend that you use it on a computer with 64GB
   of RAM, else you may run into RAM exhaustion trouble.


   Happy dictionary normalizing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help



