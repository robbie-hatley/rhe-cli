#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# unopened-zip.pl
# Lists subdirectories of the current directory which contain 1-or-more zip files but no jpg files.
# Written by Robbie Hatley.
# Edit history:
# Fri Sep 19, 2025: Wrote it.
# Tue Feb 03, 2026: Renamed to "unopened-zips.pl".
##############################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes qw( time );
use Scalar::Util qw( looks_like_number reftype );
use Regexp::Common;
use RH::Dir;
use RH::Util;

# ======= VARIABLES: =========================================================================================

# ------- System Variables: ----------------------------------------------------------------------------------

$" = ', ' ; # Quoted-array element separator = ", ".

# ------- Global Variables: ----------------------------------------------------------------------------------

our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.
our    $cmpl_beg;                              # Declare compilation begin time.
BEGIN {$cmpl_beg = time}                       # Set     compilation begin time.
our    $cmpl_end;                              # Declare compilation end   time.
INIT  {$cmpl_end = time}                       # Set     compilation end   time.

# ------- Local variables: -----------------------------------------------------------------------------------

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $OriDir    = cwd       ; # Original directory.       cwd       Directory on program entry.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 1         ; # Be verbose?               0,1,2     Be terse.

# Counters:
my $direcount = 0         ; # Count of directories processed by curdire().
my $filecount = 0         ; # Count of files matching target, regexp, and predicate.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub BLAT    ; # Print messages only if debugging.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Start execution timer:
   my $t0 = time;
   my @s0 = localtime($t0);

   # Process @ARGV and set settings:
   argv;

   # Print program entry message if being terse or verbose:
   if ( $Verbose >= 1 ) {
      printf STDERR "Now entering program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n",
                    $s0[2], $s0[1], $s0[0], 1+$s0[4], $s0[3], 1900+$s0[5];
   }

   # Print compilation time if being verbose:
   if ( $Verbose >= 2 ) {
      printf STDERR "Compilation time was %.3fms\n",
                    1000 * ($cmpl_end - $cmpl_beg);
   }

   # Print basic settings if being terse or verbose:
   if ( $Verbose >= 1 ) {
      say STDERR "Starting directory = $OriDir";
   }

   # If debugging, print the values of all variables except counters, after processing @ARGV:
   BLAT "Debug message: Values of variables after running argv():\n"
      . "pname     = $pname     \n"
      . "cmpl_beg  = $cmpl_beg  \n"
      . "cmpl_end  = $cmpl_end  \n"
      . "Options   = (@Opts)    \n"
      . "Arguments = (@Args)    \n"
      . "OriDir    = $OriDir    \n"
      . "Debug     = $Debug     \n"
      . "Help      = $Help      \n"
      . "Verbose   = $Verbose";

   print "\n" if $Verbose > 0 || $Debug > 0;

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   if ($Help) {
      help
   }
   else {
      # If "$OriDir" is a real directory, perform the program's function:
      if ( -e $OriDir && -d $OriDir ) {
         $Debug and RH::Dir::rhd_debug('on');
         my $mlor = RecurseDirs {curdire};
         print "\n" if $Verbose > 0 || $Debug > 0;
         say "Maximum levels of recursion reached = $mlor" if $Verbose >= 1;
         $Debug and RH::Dir::rhd_debug('off');
      }
      # Otherwise, just print an error message:
      else { # Severe error!
         say STDERR "Error in \"$pname\": \"original\" directory \"$OriDir\" does not exist!\n"
                  . "Skipping execution.\n"
                  . "$!";
      }
   }

   # Stop execution timer:
   my $t1 = time;
   my @s1 = localtime($t1);

   # Print exit message if being terse or verbose:
   if ( $Verbose >= 1 ) {
      my $te = $t1 - $t0; my $ms = 1000 * $te;
      printf STDERR "Now exiting program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n",
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

   # Get list of file names for non-hidden regular files in this directory:
   my @names = readdir_regexp_utf8($cwd, 'F', '^[^.]', '1');

   # Get count of zip files:
   my @zips = grep {$_ =~ m/\.zip$/} @names;
   BLAT "zips = (@zips)";
   my $zips = scalar @zips;

   # Get count of jpg files:
   my @jpgs = grep {$_ =~ m/\.jpg$/} @names;
   BLAT "jpgs = (@jpgs)";
   my $jpgs = scalar @jpgs;

   # Say $cwd if $zips > 1 and $jpgs < 1:
   say $cwd if $zips > 0 && $jpgs < 1;

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Print messages only if debugging:
sub BLAT ($string) {if ($Debug) {say STDERR $string}}

# Print help:
sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "$pname". This program prints the paths of all subdirectories
   of the current directory which contain 1-or-more zip files but no jpg files.

   -------------------------------------------------------------------------------
   Command lines:

   $pname -h | --help   (to print this help and exit)
   $pname [options]     (to find subdirs with zips but no jpgs)

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
