#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# random-lines.pl
# Given a file and a positive integer n, prints n random lines from the file.
# Written by Robbie Hatley.
# Edit history:
# Tue Oct 27, 2026: Wrote it.
# Wed Oct 28, 2026: Fixed "trying to print non-existent lines from empty input" bug.
# Tue Nov 03, 2026: Got rid of "@Opts" and "$Help". Fixed errors in help().
##############################################################################################################

use v5.40;
use utf8::all;
use Getopt::Long 'GetOptions';

# ======= VARIABLES: =========================================================================================

my $NOLTP = 10; # Number Of Lines To Print (defaults to 10).

# ======= SUBROUTINE PREDECLARATIONS: ========================================================================

sub help;

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main

   # Process @ARGV:
   GetOptions('h|help' => sub {help(); exit 0}, 'lines=i' => \$NOLTP)
   or die "Error: Getopt::Long::GetOptions() failed.\n";

   # $NOLTP must be an integer:
   $NOLTP =~ m/^0$|^-?[1-9]\d*$/
   or die "Error: Number of lines to print must be an integer.\n";

   # Slurp all lines of input text into "@lines":
   my @lines = (<>);

   # How many lines do we have?
   my $num_lines = scalar @lines;

   # If @lines is empty, exit now to avoid trying to print non-existent lines:
   $num_lines >= 1
   or die "Error: No input was received.\n";

   # Print $NOLTP random lines from input to output:
   for ( my $i = 0 ; $i < $NOLTP ; ++ $i ) {
      print $lines[int rand $num_lines];
   }

} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Print help:
sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "random-lines.pl". Given some input text and a positive integer n
   (defaulting to 10), this program will print n random lines from the input.
   Input is from files listed on command line, or from STDIN. Output is to STDOUT.

   By default, 10 lines will be printed, but by using a "--lines=#" option
   (where "#" stands for any positive integer), # lines will be printed.
   For example, this will print 57 lines:
   cat big-file.txt | random-lines.pl --lines=57

   -------------------------------------------------------------------------------
   Command lines:

   random-lines.pl -h | --help      (to print this help and exit)
   random-lines.pl [opts] [Args]    (to print random lines from input)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:        Meaning:
   -h or --help   Print this help and exit.
   --lines=#      Print # random lines from input. (Defaults to 10.)
   --             End of options (all further CL items are arguments).

   If you want to use an argument that looks like an option (say, you want to
   print lines from a file named "--myfile") use a "--" option first; that will
   force all subsequent command-line entries to be considered "arguments" rather
   than "options".

   All options not listed above will be ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   Any arguments will be construed as paths to files from which to input text.


   Happy random line printing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
