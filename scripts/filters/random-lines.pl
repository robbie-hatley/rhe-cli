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
##############################################################################################################

use v5.40;
use utf8::all;

# ======= VARIABLES: =========================================================================================

my @Opts;
my $Help  =  0 ; # Print help and exit?
my $NOLTP = 10 ; # Number Of Lines To Print (defaults to 10).

# ======= SUBROUTINE PREDECLARATIONS: ========================================================================

sub argv;
sub help;

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main

   # Process @ARGV:
   argv;

   # If user requested help, print help and exit:
   if ($Help) {
      help;
      exit;
   }

   # Slurp all lines of input text into "@lines":
   my @lines = (<>);

   # How many lines do we have?
   my $num_lines = scalar @lines;

   # If @lines is empty, exit now to avoid trying to print non-existent lines:
   exit unless $num_lines >= 1;

   # Print $NOLTP random lines from input to output:
   for ( 1 .. $NOLTP ) {
      print $lines[int rand $num_lines];
   }

} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV:
sub argv {
   # Declare and define certain variables we'll need:
   my $e = 0;                # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)

   # Pull all options OUT of @ARGV and put them in @Opts instead:
   for ( my $i = 0 ; $i <= $#ARGV ; ++$i ) {
      # If current item is end-of-options marker, remove it from @ARGV, set "$e", and consider all remaining
      # contents of @ARGV to be "arguments" rather than "options":
      if ( '--' eq $ARGV[$i] ) {
         $e = 1;
         splice @ARGV, $i, 1;
         --$i;
      }
      # If current item is an "option", remove it from @ARGV and push it to @Opts:
      elsif ( !$e && ( $ARGV[$i] =~ /^-(?!-)$s+$/ || $ARGV[$i] =~ /^--(?!-)$d+$/ ) ) {
         push @Opts, splice @ARGV, $i, 1;
         --$i;
      }
      # Otherwise, this item is an argument, so leave it in @ARGV:
      else {
         ; # Do nothing.
      }
   }

   # Process options:
   for ( @Opts ) {
      /^-$s*h/ || /^--help$/ and $Help = 1;
      /^--lines=([1-9]\d*)$/ and $NOLTP = $1;
   }

   # @ARGV now contains NO options. If any items remain, they will be construed by the (<>) operator as being
   # files to be input, filtered, and output.

   # Return success code 1 to caller:
   return 1;
} # end sub argv

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

   asdf.pl -h | --help      (to print this help and exit)
   asdf.pl [opts] [Args]    (to print random lines from input)

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

   Any arguments will be construed as paths to files to be input from.


   Happy random line printing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
