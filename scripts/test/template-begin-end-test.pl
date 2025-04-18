#!/usr/bin/env -S perl -C63
##############################################################################################################
# template-begin-end-test.pl
##############################################################################################################

# Pragmas:
use v5.36;
use utf8;

# CPAN modules:
use Cwd;
use Time::HiRes 'time';
use Scalar::Util qw( looks_like_number reftype );
use List::AllUtils;

# RH modules:
use RH::Dir;
use RH::Util;

# ======= VARIABLES: =========================================================================================

# System Variables:
$" = ', ' ; # Quoted-array element separator = ", ".

# Timers:
our $t0; # Time in seconds since 00:00:00 UTC on Jan 01, 1970, at time of program entry
our $t1; # Time in seconds since 00:00:00 UTC on Jan 01, 1970, at time of program exit

# WARNING: Don't initialize variables here in the variable-declarations part of the program, because that
# would undo the values stored in these variables by BEGIN and by argv (which is called by BEGIN).

# The order of operations is like this:
# 1. All "our" declarations are obeyed but the part from "=" to end of line is deferred to Step 3.
# 2. All "BEGIN{}" blocks are run. They can only see subroutines DEFINED lexically above them on the page.
# 3. All top-level "our" and "my" assignments using "=" are performed. (So don't do that, if using BEGIN.)
# 4. All subroutines are compiled.
# 5. The main body of the script (all code to-be-executed which is not in any subroutine) is compiled.
# 6. The main body of the script is executed.
# 7. The script is exited.
# 8. All "END{}" blocks are run.

# Settings variables:
our $pname     ; # Name of this program.
our @opts      ; # options
our @args      ; # arguments
our $Db        ; # Debug?
our $Help      ; # Just print help and exit?
our $Verbose   ; # Be verbose?
our $Recurse   ; # Recurse subdirectories?
our $Target    ; # Target
our $RegExp    ; # Regular expression.
our $Predicate ; # Boolean predicate.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire().

# ======= SUBROUTINES: =======================================================================================

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "[insert Program Name here]". This program does blah blah blah
   to all files in the current directory (and all subdirectories if a -r or
   --recurse option is used).

   -------------------------------------------------------------------------------
   Command lines:

   program-name.pl -h | --help                       (to print this help and exit)
   program-name.pl [options] [Arg1] [Arg2] [Arg3]    (to [perform funciton] )

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics.
   -q or --quiet      Be quiet.                         (DEFAULT)
   -t or --terse      Be terse.
   -v or --verbose    Be verbose.
   -l or --local      DON'T recurse subdirectories.     (DEFAULT)
   -r or --recurse    DO    recurse subdirectories.
   -f or --files      Target Files.
   -d or --dirs       Target Directories.
   -b or --both       Target Both.
   -a or --all        Target All.                       (DEFAULT)
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively process items.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: heabdfrlvtq.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   This program ignores all arguments.

   END_OF_HELP
   return 1;
} # end sub help

# Handle errors:
sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most
   2 arguments (an optional file-selection regexp and an optional
   file-selection predicate). Help follows:
   END_OF_ERROR
   return 1;
} # end sub error

# Process @ARGV :
sub argv {
   # Initialize global ("our") settings variables:
   # Settings:      Default:      Meaning of setting:       Range:    Meaning of default:
   $pname         = ''        ; # Name of this program.     string    blank
   @opts          = ()        ; # options                   array     Options.
   @args          = ()        ; # arguments                 array     Arguments.
   $Db            = 0         ; # Debug?                    bool      Don't debug.
   $Help          = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
   $Verbose       = 0         ; # Be verbose?               bool      Shhhh!! Be quiet!!
   $Recurse       = 0         ; # Recurse subdirectories?   bool      Don't recurse.
   $Target        = 'A'       ; # Target                    F|D|B|A   All directory entries.
   $RegExp        = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
   $Predicate     = 1         ; # Boolean predicate.        bool      Process all file types.

   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV,
      /^--$/ && !$end        # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1           # so if we see that, then set the "end-of-options" flag
      and push @opts, $_     # and push the "--" to @opts
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we get a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @opts, $_     # then push item to @opts
      or  push @args, $_;    # else push item to @args.
   }

   say STDERR "In argv.  opts = (@opts)  args = (@args)";

   # Process options:
   for ( @opts ) {
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
      /^-$s*e/ || /^--debug$/   and $Db      =  1  ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0  ; # Default.
      /^-$s*t/ || /^--terse$/   and $Verbose =  1  ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2  ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0  ; # Default.
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1  ;
      /^-$s*f/ || /^--files$/   and $Target  = 'F' ;
      /^-$s*d/ || /^--dirs$/    and $Target  = 'D' ;
      /^-$s*b/ || /^--both$/    and $Target  = 'B' ;
      /^-$s*a/ || /^--all$/     and $Target  = 'A' ; # Default.
   }

   # Ignore all arguments:
   ;

   say STDERR "About to return from argv. Verbose = $Verbose and Debug = $Db";

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Increment directory counter:
   ++$direcount;

   # Get current working directory:
   my $cwd = d getcwd;

   # Announce current working directory if being at-least-somewhat-verbose:
   if ( $Verbose >= 1) {
      say "\nDirectory # $direcount: $cwd\n";
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Print statistics for this program run:
sub stats {
   # If being terse or verbose, print basic stats to STDERR:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say    STDERR '';
      say    STDERR 'Statistics for this directory tree:';
      say    STDERR "Navigated $direcount directories.";
   }
   return 1;
} # end sub stats

# ======= BEGIN BLOCK: =======================================================================================

BEGIN {
   say STDERR "Now entering BEGIN block.";
   argv;
   $t0 = time;
   $pname = substr $0, 1 + rindex $0, '/';
   say STDERR '';
   say STDERR "Now entering program \"$pname\" at timestamp $t0.";
   say STDERR "t0        = $t0";
   say STDERR "t1        = $t1";
   say STDERR "pname     = $pname";
   say STDERR "Options   = (", join(', ', map {"\"$_\""} @opts), ')';
   say STDERR "Arguments = (", join(', ', map {"\"$_\""} @args), ')';
   say STDERR "Db        = $Db";
   say STDERR "Help      = $Help";
   say STDERR "Verbose   = $Verbose";
   say STDERR "Recurse   = $Recurse";
   say STDERR "Target    = $Target";
   say STDERR "RegExp    = $RegExp";
   say STDERR "Predicate = $Predicate";
   say STDERR "Now exiting BEGIN block.";
}

# ======= MAIN BODY OF PROGRAM: ==============================================================================

say STDERR 'Now entering main body.';
say STDERR '';
say STDERR "t0        = $t0";
say STDERR "t1        = $t1";
say STDERR "pname     = $pname";
say STDERR "Options   = (", join(', ', map {"\"$_\""} @opts), ')';
say STDERR "Arguments = (", join(', ', map {"\"$_\""} @args), ')';
say STDERR "Db        = $Db";
say STDERR "Help      = $Help";
say STDERR "Verbose   = $Verbose";
say STDERR "Recurse   = $Recurse";
say STDERR "Target    = $Target";
say STDERR "RegExp    = $RegExp";
say STDERR "Predicate = $Predicate";
$Help and help or ($Recurse and RecurseDirs {curdire} or curdire) and stats;
say STDERR 'Now exiting main body.';
exit 0;

# ======= END BLOCK: =========================================================================================

END {
   say STDERR "Now entering END block.";
   $t1 = time;
   say STDERR '';
   say STDERR "t0        = $t0";
   say STDERR "t1        = $t1";
   say STDERR "pname     = $pname";
   say STDERR "Options   = (", join(', ', map {"\"$_\""} @opts), ')';
   say STDERR "Arguments = (", join(', ', map {"\"$_\""} @args), ')';
   say STDERR "Db        = $Db";
   say STDERR "Help      = $Help";
   say STDERR "Verbose   = $Verbose";
   say STDERR "Recurse   = $Recurse";
   say STDERR "Target    = $Target";
   say STDERR "RegExp    = $RegExp";
   say STDERR "Predicate = $Predicate";
   say STDERR "Now exiting END block.";
}
