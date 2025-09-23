#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# unopened-zip.pl
# Finds directories with exactly 1 non-hidden regular file which is a zip file.
# Written by Robbie Hatley.
# Edit history:
# Fri Sep 19, 2025: Wrote it.
##############################################################################################################

# Pragmas:
use v5.36;

# Essential CPAN Modules:
use utf8::all;
use Cwd::utf8;
use Time::HiRes qw( time );

# Extra CPAN Modules:
use Scalar::Util qw( looks_like_number reftype );
use Regexp::Common;
use Unicode::Normalize;
use Unicode::Collate;
use MIME::QuotedPrint;

# Essential RH Modules:
use RH::Dir;        # Recurse directories; get list of file-info packets for names matching a regexp; etc.
use RH::Util;       # Unbuffered single-keystroke inputs; etc.

# Extra RH modules:
use RH::Math;       # Math routines.
use RH::RegTest;    # Test regular expressions.
use RH::WinChomp;   # "chomp" for Microsoft Windows.

# ======= VARIABLES: =========================================================================================

# ------- System Variables: ----------------------------------------------------------------------------------

$" = ', ' ; # Quoted-array element separator = ", ".

# ------- Global Variables: ----------------------------------------------------------------------------------

our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.

# ------- Local variables: -----------------------------------------------------------------------------------

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 1         ; # Be verbose?               0,1,2     Be terse.
my $OriDir    = cwd       ; # Original directory.       cwd       Directory on program entry.

# Counters:
my $direcount = 0         ; # Count of directories processed by curdire().
my $filecount = 0         ; # Count of files matching target, regexp, and predicate.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

# NOTE: These alert the compiler that these names, when encountered (whether in subroutine definitions,
# BEGIN, CHECK, UNITCHECK, INIT, END, other subroutines, or in the main body of the program), are subroutines,
# so it needs to find, compile, and link their definitions:
sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub BLAT    ; # Print messages only if debugging.
sub stats   ; # Print statistics.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Start execution timer:
   my $t0 = time;
   my @s0 = localtime($t0);

   # Process @ARGV and set settings:
   argv;

   # Print program entry message if being verbose:
   if ( $Verbose >= 2 ) {
      printf STDERR "Now entering program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n\n",
                    $s0[2], $s0[1], $s0[0], 1+$s0[4], $s0[3], 1900+$s0[5];
   }

   # Process current directory and all subdirectories and print stats,
   # unless user requested help, in which case just print help:
   if ($Help) {
      help;
   }
   else {
      my $mlor = RecurseDirs {curdire};
      say "\nMaximum levels of recursion reached = $mlor";
   }

   # Stop execution timer:
   my $t1 = time;
   my @s1 = localtime($t1);

   # Print exit message if being verbose:
   if ( $Verbose >= 2 ) {
      my $te = $t1 - $t0; my $ms = 1000 * $te;
      printf STDERR "\nNow exiting program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n",
                    $s1[2], $s1[1], $s1[0], 1+$s1[4], $s1[3], 1900+$s1[5];
      printf STDERR "Execution time was %.3fms.\n", $ms;
   }

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV:
sub argv {
   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV:
      !$end                  # If we have not yet reached end-of-options,
      && /^--$/              # and we see an "--" option,
      and $end = 1           # set the "end-of-options" flag
      and push @Opts, '--'   # and push "--" to @Opts
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we have not yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we see a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @Opts, $_     # then push item to @Opts
      and next;              # and skip to next element of @ARGV.
      push @Args, $_;        # Otherwise, push item to @Args.
   }

   # Process options:
   for ( @Opts ) {
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
      /^-$s*e/ || /^--debug$/   and $Debug   =  1  ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0  ;
      /^-$s*t/ || /^--terse$/   and $Verbose =  1  ; # Default.
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2  ;
   }

   # This program ignores all arguments.

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Increment directory counter:
   ++$direcount;

   # Get current working directory:
   my $cwd = cwd;

   # Get list of file records for non-hidden regular files in this directory:
   my @files = @{GetFiles($cwd, 'F', '^[^.]')};
   my $n = scalar(@files);

   # If size of list is 1:
   if ( 1 == scalar @files ) {
      # If that one file has extension ".zip":
      if ( $files[0]->{Name} =~ m/\.zip$/ ) {
         # Print the path of the current directory:
         say $cwd;
      }
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Print messages only if debugging:
sub BLAT ($string) {if ($Debug) {say STDERR $string}}

# Print help:
sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "unopened-zip.pl". This program prints the paths of all
   subdirectories of the current directory which contain exactly 1 non-hidden
   regular file which is a zip file.

   -------------------------------------------------------------------------------
   Command lines:

   unopened-zip.pl -h | --help   (to print this help and exit)
   unopened-zip.pl [options]     (to find dirs containing only a single zip file)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.
   -e or --debug      Print diagnostics.
   -q or --quiet      Be quiet.
   -t or --terse      Be terse.                         (DEFAULT)
   -v or --verbose    Be verbose.

   Multiple single-letter options may be piled-up after a single hyphen.

   If multiple conflicting separate options are given, latter overrides former.

   If multiple conflicting single-letter options are piled after a single hyphen,
   the precedence is the inverse of the options in the above table.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   This program ignores all arguments.


   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
