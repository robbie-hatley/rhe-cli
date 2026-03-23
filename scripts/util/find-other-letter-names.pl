#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# find-other-letter-names.pl
#
# Finds files which have names containing "other" (unicameral or ideographic) letters, Perl Unicode Property
# "\p{Lo}".
#
# Written by Robbie Hatley.
#
# Edit history:
# Mon Mar 15, 2021: Wrote it.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Sat Nov 27, 2021: Shortened sub names. Fixed regexp bug that was causing program to find no files.
# Thu Oct 03, 2024: Got rid of Sys::Binmode and common::sense; added "use utf8".
# Mon Oct 07, 2024: Added "use warnings FATAL => 'utf8';", as this program deals with elaborate UTF-8 names.
#                   Also upgraded to "v5.36" with prototypes and signatures.
# Wed Mar 19, 2025: Modernized. Now offers many more options. Can now pile-up single-letter options after a
#                   single hyphen. Can now use both regexps and predicates to select files to process.
#                   Shortened width from 120 to 110. Put "-C63" in shebang.
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e".
# Sun Mar 22, 2026: Changed name from "find-ideographic-names.pl" to "find-other-letter-names.pl" because
#                   this script checks for presence of characters matching "\p{Lo}" ("other letters"), and
#                   that property matches many syllabic, unicameral, non-ideographic letters, such as the
#                   entire "Canadian Aboriginal" character set. Added variable "$OriDir". Changed "$ideocount"
#                   to "$othlcount". Now uses local time for start and end times.
#                   Fixed logic error in "argv" which was causing arguments to be skipped.
##############################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
use RH::Dir;

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
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 1         ; # Be verbose?               0,1,2     Be terse.
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $Target    = 'A'       ; # Target                    F|D|B|A   All directory entries.
my $RegExp    = qr/^.+$/s ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.
my $OriDir    = cwd       ; # Original directory.       cwd       Directory on program entry.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire().
my $filecount = 0 ; # Count of files matching cwd, Target, RegExp, and Predicate.
my $othlcount = 0; # Count of dir entries matching regexps.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Start execution timer:
   my $t0 = time;
   my @s0 = localtime($t0);

   # Process @ARGV and set settings:
   argv;

   # Print program entry message if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say    STDERR "\nNow entering program \"$pname\"";
      printf STDERR "at %02d:%02d:%02d on %d/%d/%d.\n", $s0[2], $s0[1], $s0[0], 1+$s0[4], $s0[3], 1900+$s0[5];
      say    STDERR '';
   }

   # Also print compilation time if being verbose:
   if ( 2 == $Verbose ) {
      printf(STDERR "Compilation time was %.3fms\n",1000*($cmpl_end-$cmpl_beg));
      say STDERR '';
   }

   # Print the starting values of all non-counter variables if debugging:
   if ( 1 == $Debug ) {
      say STDERR "pname     = $pname";
      say STDERR "cmpl_beg  = $cmpl_beg";
      say STDERR "cmpl_end  = $cmpl_end";
      say STDERR "Options   = (@Opts)";
      say STDERR "Arguments = (@Args)";
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR "Verbose   = $Verbose";
      say STDERR "Recurse   = $Recurse";
      say STDERR "Target    = $Target";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR '';
   }

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   if ($Help) {
      help
   }
   else {
      # If "$OriDir" is a real directory, perform the program's function:
      if ( -e $OriDir && -d $OriDir ) {
         $Debug and RH::Dir::rhd_debug('on');
         if ($Recurse) {
            my $mlor = RecurseDirs {curdire};
            say "\nMaximum levels of recursion reached = $mlor" if $Verbose >= 1;
         }
         else {
            curdire;
         }
         $Debug and RH::Dir::rhd_debug('off');
         stats if $Verbose >= 1;
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
   if ( 1 == $Verbose || 2 == $Verbose ) {
      my $ms = 1000 * ($t1 - $t0);
      say    STDERR '';
      say    STDERR "Now exiting program \"$pname\"";
      printf STDERR "at %02d:%02d:%02d on %d/%d/%d. ", $s1[2], $s1[1], $s1[0], 1+$s1[4], $s1[3], 1900+$s1[5];
      printf STDERR "Execution time was %.3fms.", $ms;
   }

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV and set settings:
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
      push @Args, $_;        # If we get to here, push item to @Args.
   }

   # Process options:
   for ( @Opts ) {
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
      /^-$s*e/ || /^--debug$/   and $Debug   =  1  ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0  ;
      /^-$s*t/ || /^--terse$/   and $Verbose =  1  ; # Default.
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2  ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0  ; # Default.
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1  ;
      /^-$s*f/ || /^--files$/   and $Target  = 'F' ;
      /^-$s*d/ || /^--dirs$/    and $Target  = 'D' ;
      /^-$s*b/ || /^--both$/    and $Target  = 'B' ;
      /^-$s*a/ || /^--all$/     and $Target  = 'A' ; # Default.
   }

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If user typed more than 2 arguments, warn that extra arguments will be ignored:
   if ( $NA > 2 ) {
      warn "\nWarning: All arguments after the first 2 will be ignored;\n"
          ."use a -h or --help option to get help.\n";
   }

   # First argument, if present, is a file-selection regexp:
   if ( $NA > 0 ) {              # If number of arguments > 0,
      $RegExp = qr/$Args[0]/o;   # set $RegExp to $Args[0].
   }

   # Second argument, if present, is a file-selection predicate:
   if ( $NA > 1 ) {              # If number of arguments >= 2,
      $Predicate = $Args[1];     # set $Predicate to $Args[1].
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Increment directory counter:
   ++$direcount;

   # Get current working directory:
   my $cwd = cwd;

   # If being verbose, announce cwd:
   say "\nDirectory # $direcount: $cwd\n" if $Verbose >= 2;

   # Get list of file names $cwd matching $Target, $RegExp, and $Predicate:
   my @names = sort {$a cmp $b} readdir_regexp_utf8($cwd, $Target, $RegExp, $Predicate);

   # Iterate through $names and send each name to curfile():
   foreach my $name (@names) {curfile($cwd, $name)}

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($cwd, $name) {
   # Increment file counter:
   ++$filecount;
   # If $name contains at least one "other" (ideographic or unicameral) letter,
   # increment counter and print path:
   if ( $name =~ m/\p{Lo}/ ) {
      ++$othlcount;
      say path($cwd, $name);
   }
   return 1;
} # end sub curfile

# Print stats:
sub stats {
   warn "\nStatistics for running program \"$pname\"\n"
       ."on directory tree descending from \"$OriDir\":\n"
       ."Navigated $direcount directories.\n"
       ."Processed $filecount files.\n"
       ."Found $othlcount files with names containing \"other\" letters.\n";
   return 1;
} # end sub stats

# Print help:
sub help {
   print ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "$pname". This program finds all files
   in the current directory (and all subdirectories if a -r or --recurse
   option is used) which have names containing "other" (ideographic or unicameral)
   letters, matching the Perl Unicode Properties descriptor "\p{Lo}",
   and prints their fully-qualified paths.

   -------------------------------------------------------------------------------
   Command lines:

   $pname  -h | --help            (to print help)
   $pname  [options] [arguments]  (to find files)

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

   If multiple conflicting separate options are given, latter overrides former.

   If multiple conflicting single-letter options are piled after a single hyphen,
   the precedence is the inverse of the options in the above table.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   In addition to options, this program can take 1 or 2 optional arguments.

   Arg1 (OPTIONAL), if present, must be a Perl-Compliant Regular Expression
   specifying which file names to process. To specify multiple patterns, use the
   | alternation operator. To apply pattern modifier letters, use an Extended
   RegExp Sequence. For example, if you want to process items with names
   containing "cat", "dog", or "horse", title-cased or not, you could use this
   regexp: '(?i:c)at|(?i:d)og|(?i:h)orse'
   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   Arg2 (OPTIONAL), if present, must be a boolean predicate using Perl
   file-test operators. The expression must be enclosed in parentheses (else
   this program will confuse your file-test operators for options), and then
   enclosed in single quotes (else the shell won't pass your expression to this
   program intact). Here are some examples of valid and invalid predicate arguments:
   '(-d && -l)'  # VALID:   Finds symbolic links to directories
   '(-l && !-d)' # VALID:   Finds symbolic links to non-directories
   '(-b)'        # VALID:   Finds block special files
   '(-c)'        # VALID:   Finds character special files
   '(-S || -p)'  # VALID:   Finds sockets and pipes.  (S must be CAPITAL S   )
    '-d && -l'   # INVALID: missing parentheses       (confuses program      )
    (-d && -l)   # INVALID: missing quotes            (confuses shell        )
     -d && -l    # INVALID: missing parens AND quotes (confuses prgrm & shell)

   Arguments and options may be freely mixed, but the arguments must appear in
   the order Arg1, Arg2 (RegExp first, then File-Type Predicate); if you get them
   backwards, they won't do what you want, as most predicates aren't valid regexps
   and vice-versa.

   NOTE: You can't "skip" Arg1 and go straight to Arg2 because your intended Arg2
   would be construed as Arg1! But you can "bypass" Arg1 by using '.+' meaning
   "some characters" which will match every file name.

   Any arguments after the first 2 will be ignored.

   WARNING: Do not try to use "--" as an argument! That will not work, as that is
   this program's "end of options" indicator.

   Happy file finding!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
