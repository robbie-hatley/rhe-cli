#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# number-dreams.pl
# This program numbers a dream log, provided that each dream in the log is prefaced by line containing only a
# string of exactly 49 "~" characters, and that the file is a UTF-8-transformed Unicode-encoded text file, and
# that the line endings are Unix/Linux Line Feed = "\n" = "\x0A". The original dream log is input via STDIN
# and is not altered. The numbered dream log is output to STDOUT so that it may be redirected to a file.
#
# Written by Robbie Hatley on Monday December 8, 2025CEG.
#
# Edit history:
# Mon Dec 08, 2025: Wrote it.
# Sun Sep 06, 2026: Added colophon, title block, and help.
##############################################################################################################

use v5.16;
use utf8::all;

# ======= VARIABLES: =========================================================================================

# ------- Local variables: -----------------------------------------------------------------------------------

# Settings:     Default:      Meaning of setting:
my @Opts      = ()        ; # Options.
my $Number    = 49        ; # Number of repetitions in divider.
my $Divider   = '~'       ; # Divider phrase to be repeated.
my $Word      = 'Dream'   ; # Type of item being numbered.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv;
sub help;

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Process @ARGV:
   argv;
   # Announce settings:
   say "Repetition number = $Number ";
   say "Divide character  = $Divider";
   say "Label word        = $Word   ";
   # Initialize a "next line is expected to be dream number" flag to 0:
   my $next_is_dream = 0;
   # Initialize a "dream number" counter to 1 (so that first dream number will be 1):
   my $n = 1;
   # Set variable "$_" to each line of STDIN and/or files named by arguments in-turn:
   while (<>) {
      # Chomp BOM (if any) from beginning of $_:
      s/^\N{BOM}//;
      # Chomp newline (if any) from end of $_:
      chomp;
      # If current line is expected to be a "Dream #" line, print the correct dream #:
      if ($next_is_dream) {
         # If current line is dream number:
         if (/^$Word #(\d+)$/) {
            # If the number is correct, just print the line verbatim:
            if ($1 == $n) {
               say;
            }
            # If the number is wrong, print corrected version instead:
            else {
               say "$Word #", $n;
            }
         }
         # Else if current line is NOT dream number, print dream number then print current line:
         else {
            say "$Word #", $n;
            say;
         }
         # Increment dream counter:
         ++$n;
         # Clear "next is dream" flag:
         $next_is_dream = 0;
      }
      # Otherwise if the current line is NOT expected to be a "Dream #" line, just print it verbatim:
      else {
         say;
      }
      # If current line is a divider, set the "next_is_dream" flag:
      if (/^(?:\Q${Divider}\E){$Number}$/) {
         $next_is_dream = 1;
      }
   }
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
      /^--number=(.+)$/    and $Number  = $1;
      /^--divider=(.+)$/   and $Divider = $1;
      /^--word=(.+)$/      and $Word    = $1;
   }

   # Finally, return success code 1 to caller:
   return 1;
}

# Print help:
sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "number-dreams.pl". This program numbers a dream log, provided that
   each dream in the log is preceded by a line containing only a string of exactly
   49 "~" characters, and that the file is a UTF-8-transformed Unicode-encoded
   text file, and that the line endings are Unix/Linux Line Feed = "\n" = "\x0A".

   The original dream log is input from the files listed on the command line
   (or from STDIN if no files are listed). The input files are not altered.
   The numbered dream log is output to STDOUT and may be redirected to a file.

   Each line containing only a string of exactly 49 tildes will be considered the
   start of a dream. Each "49 tildes" line will be expected to be followed by a
   line of the form "Dream #239". If the dream-number line does not exist, it will
   be created. If the dream-number line does exist, it will be checked for
   numerical correctness. Correctly-numbered dream-number lines will be printed
   verbatim. Incorrectly-numbered dream-number lines will be corrected
   as necessary. The first dream will be forced to have dream number 1, and every
   other dream will be forced to have a dream number one-greater-than that of the
   preceding dream.

   All lines of text other than dream-number lines will be printed verbatim.

   Note: You can also use this program to number things other than dream logs,
   and you can use dividers other than "a string of 49 tildes"; see "options"
   below.

   -------------------------------------------------------------------------------
   Command lines:

   number-dreams.pl -h | --help                           (to get help)
   number-dreams.pl [options] in1.txt in2.txt > out.txt   (to number dreams)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:        Meaning:
   -h or --help   Print this help and exit.
   --number=36    Use 36 (or other number) repetitions in divider instead of 49.
   --divider=-    Use repeated "-" (or some other string) instead of "~".
   --word=Item    Use "Item" (or some other string) instead of "Dream".

   To use a divider other than a string of 49 tildes, use the "--divider=" option.

   If you want to use this program to number things other than dreams, you can
   substitute any string in place of "Dream" by using the "--word=" option.

   For example, to number a recipe file using a string of 40 Ws as divider:
   number-dreams.pl --number=40 --divider=W --word=Recipe in.txt > out.txt

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   All non-option arguments will be considered to be paths to files and will be
   input, concatenated, numbered, and output, in the order received.


   Happy dream numbering!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
