#!/usr/bin/env perl

# This is a 110-character-wide ASCII Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# /rhe/scripts/util/rand-ascii.pl
# Generates a specified number of rows of a specified number of columns of
# random ASCII text (letters and spaces only). Numbers of rows and columns
# are given by $ARGV[0] and $ARGV[1] respectively.
# Edit history:
#    Sat Jan 10, 2015: Wrote it.
#    Fri Jul 17, 2015: Minor cleanup (comments, etc).
#    Sun Nov 11, 2018: Added numbers and symbols, debugging, and argument processing.
#    Tue Mar 11, 2025: Updated to my latest formatting. Changed encoding from UTF-8 to ASCII. Reduced with
#                      from 120 to 110.
##############################################################################################################

# ======= PRAGMAS: ===========================================================================================

use strict;
use warnings;

# ======= VARIABLES: =========================================================================================

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Db        = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Rows      = 20        ; # Number of rows.           pos int   20 rows.
my $Cols      = 70        ; # Number of columns.        pos int   70 columns.

# Character set and number of characters:
my $chars =
"ABCDEFGHIJKLMNOPQRSTUVWXYZ".
"abcdefghijklmnopqrstuvwxyz".
"abcdefghijklmnopqrstuvwxyz".
"abcdefghijklmnopqrstuvwxyz".
"012345678901234567890123456789".
'`~!@#$%^&*()-_=+[{]};:\'",<.>/?|\\'.
"                          ";
my $numchars = length $chars;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub debug   ; # Print settings and exit.
sub prgib   ; # Print gibberish.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   argv;
   $Db and debug and exit(888)
   or $Help and help and exit(777)
   or prgib and exit(0);
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV :
sub argv {
   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV,
      /^--$/ && !$end        # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1           # so if we see that, then set the "end-of-options" flag
      and push @Opts, $_     # and push the "--" to @opts
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we get a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @Opts, $_     # then push item to @opts
      or  push @Args, $_;    # else push item to @args.
   }

   # Process options:
   for ( @Opts ) {
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
      /^-$s*e/ || /^--debug$/   and $Db      =  1  ;
   }

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If user typed more than 2 arguments, and we're not debugging or getting help, print error msg and exit:
   if ( $NA > 2                  # If number of arguments >= 3
        && !$Db && !$Help ) {    # and we're not debugging or getting help,
      error($NA);                # print error message
      exit 666;                  # and exit, returning The Number Of The Beast.
   }

   # First argument, if present, is number of rows:
   if ( $NA > 0 ) {              # If number of arguments > 0,
      $Rows = $Args[0];          # set $Rows to $Args[0].
   }

   # Second argument, if present, is a number of columns:
   if ( $NA > 1 ) {              # If number of arguments > 1,
      $Cols = $Args[1];          # set $Cols to $Args[1].
   }

   # Sanity checks for settings:
   if ( !$Db && !$Help ) {
      $Rows !~ m/^[1-9]\d*$/    and die "Error: first  argument must be an integer,  1-1000.";
      $Cols !~ m/^[1-9]\d*$/    and die "Error: second argument must be an integer,  1-1000.";
      $Rows < 1 || $Rows > 1000 and die "Error: first  argument must be in the range 1-1000.";
      $Cols < 1 || $Cols > 1000 and die "Error: second argument must be in the range 1-1000.";
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Print settings and exit:
sub debug {
   print "Character set     = \"$chars\"\n"
        ."Number of chars   = $numchars\n"
        ."Number of rows    = $Rows\n"
        ."Number of columns = $Cols\n";
}

# Print gibberish:
sub prgib {
   for ( my $i = 0 ; $i < $Rows ; ++$i ) {
      for ( my $j = 0 ; $j < $Cols ; ++$j ) {
         my $nextchar = substr $chars, int rand $numchars, 1;
         print "$nextchar";
      }
      print "\n";
   }
}

# Handle errors:
sub error {
   my $NA = shift @_ ;
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most
   2 arguments (an optional "number of rows" an optional
   "number of columns"). Use "--help" or "-h" to get help.
   END_OF_ERROR
   return 1;
} # end sub error

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "rand-ascii.pl", Robbie Hatley's nifty generator of random ASCII
   gibberish. By default, this program generates 20 rows and 70 columns of
   gibberish, but that can be altered (see options and arguments below).

   -------------------------------------------------------------------------------
   Command lines:

   rand-ascii.pl -h | --help                      (to print this help and exit)
   rand-ascii.pl [NumRows] [NumCols] -e|--debug   (to print settings and exit)
   rand-ascii.pl [NumRows] [NumCols]              (to print ASCII gibberish)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics.

   Those two options conflict. If you use both, help will be printed and the
   "debug" option will be ignored. Either option will preclude actually
   printing gibberish.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   In addition to options, this program can take 1 or 2 optional arguments.

   Arg1 (OPTIONAL), if present, must be a positive integer in the range 1-1000
   giving number of rows of gibberish to print. (Defaults to 20 rows, 70 cols.)

   Arg2 (OPTIONAL), if present, must be a positive integer in the range 1-1000
   giving number of columns of gibberish to print. (Defaults to 70 col.)

   Arguments and options may be freely mixed, but the arguments must appear in
   the order Arg1, Arg2, or they won't do what you want.

   A number of arguments greater than 2 will cause this program to print an error
   message and abort.

   Happy random ASCII gibberish printing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help


