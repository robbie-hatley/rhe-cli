#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# for-each-file.pl
# Does some command for each file in current directory.
#
# Edit history:
# Mon May 04, 2015: Wrote first draft. STUB.
# Wed May 13, 2015: Changed Help to "Here Document" format. STUB.
# Thu Jun 11, 2015: Corrected a few minor issues. STUB.
# Fri Jul 17, 2015: Upgraded for utf8. Still a STUB.
# Sat Apr 16, 2016: Now using -CSDA. Also gave it some functionality. No longer a complete stub, but not
#                   yet ready for prime time. Still very buggy.
# Fri Jan 15, 2021: Refactored.
# Wed Feb 17, 2021: Now using the new GetFiles(), which now requires a fully-qualified directory as
#                   its first argument, target as second, and regexp (instead of wildcard) as third.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Sat Nov 27, 2021: Shortened sub names, fixed wide character error (due to missing e), and now printing each
#                   command line immediately before executing it. Tested: Works.
# Thu Oct 03, 2024: Got rid of Sys::Binmode and common::sense; added "use utf8".
# Mon Mar 03, 2025: Changed shebang to "#!/usr/bin/env -S perl -C63". Reduced width from 120 to 110.
#                   Increased min ver from "5.32" to "5.36" to get signatures. Removed all prototypes.
# Wed Mar 05, 2025: Consolidated changes from Glide and home. (Corrected help, etc.)
# Fri Mar 07, 2025: Refactored. Now also using $Predicate. Updated variables, argv(), and help().
# Thu Apr 17, 2025: Fixed "applies command to dirs in files-only mode" bug (don't reset target if pred used).
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e".
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
my $Verbose   = 0         ; # Be verbose?               0,1,2     Shhh! Be quiet!
my $OriDir    = cwd       ; # Original directory.       cwd       Directory on program entry.
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $Target    = 'A'       ; # Target                    F|D|B|A   Target all directory entries.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.
my $Command               ; # Command.                  command   Not defined.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire().
my $filecount = 0 ; # Count of files matching target, regexp, and predicate.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
sub error   ; # Handle errors.
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
      printf STDERR "Now entering program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n\n",
                    $s0[2], $s0[1], $s0[0], 1+$s0[4], $s0[3], 1900+$s0[5];
   }

   # Print compilation time if being verbose:
   if ( $Verbose >= 2 ) {
      printf STDERR "Compilation time was %.3fms\n\n",
                    1000 * ($cmpl_end - $cmpl_beg);
   }

   # Print basic settings if being terse or verbose:
   if ( $Verbose >= 1 ) {
      say STDERR "OriDir    = $OriDir";
      say STDERR "Recurse   = $Recurse";
      say STDERR "Target    = $Target";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR '';
   }

   # If debugging, print the values of all variables except counters, after processing @ARGV:
   if ( $Debug >= 1 ) {
      say STDERR 'Debug: Values of variables after processing @ARGV:';
      say STDERR "pname     = $pname";
      say STDERR "cmpl_beg  = $cmpl_beg";
      say STDERR "cmpl_end  = $cmpl_end";
      say STDERR "Options   = (@Opts)";
      say STDERR "Arguments = (@Args)";
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR "Verbose   = $Verbose";
      say STDERR "OriDir    = $OriDir";
      say STDERR "Recurse   = $Recurse";
      say STDERR "Target    = $Target";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR '';
   }

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   if ($Help) {
      help;
   }
   else {
      $Recurse and RecurseDirs {curdire} or curdire;
      stats;
   }

   # Stop execution timer:
   my $t1 = time;
   my @s1 = localtime($t1);

   # Print exit message if being terse or verbose:
   if ( $Verbose >= 1 ) {
      my $te = $t1 - $t0; my $ms = 1000 * $te;
      printf STDERR "\nNow exiting program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n",
                    $s1[2], $s1[1], $s1[0], 1+$s1[4], $s1[3], 1900+$s1[5];
      printf STDERR "Execution time was %.3fms.", $ms;
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

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If user typed less-than-1 or greater-than-3 arguments,
   # and we're not getting help,
   # then print error and help messages and exit:
   if ( ($NA < 1 || $NA > 3)     # If number of arguments < 1 or > 3,
        && !$Help ) {            # and we're not getting help,
      error($NA);                # print error message,
      help;                      # and print help message,
      exit 666;                  # and exit, returning The Number Of The Beast.
   }

   # First argument is a command:
   $Command = $Args[0];          # Set $Command to $Args[0].

   # Second argument, if present, is a file-name regexp:
   if ( $NA >= 2 ) {             # If number of arguments >= 2,
      $RegExp = qr($Args[1])o;   # set $RegExp to $Args[1].
   }

   # Third argument, if present, is a file-attributes predicate:
   if ( 3 == $NA ) {             # If number of arguments is 3,
      $Predicate = $Args[2];     # set $Predicate to $Args[2].
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

   # Announce current working directory if being verbose:
   if ( $Verbose >= 2 ) {
      say STDERR "\nDirectory # $direcount: $cwd\n";
   }

   # Get sorted list of paths in $cwd matching $Target, $RegExp, and $Predicate:
   my @paths = sort {$a cmp $b} glob_regexp_utf8($cwd, $Target, $RegExp, $Predicate);

   # Send each path to curfile():
   foreach my $path (@paths) {curfile($path)}

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

sub curfile ($path) {
   # Increment file counter:
   ++$filecount;

   # Announce and execute command:
   say '';
   say    "$Command '$path'";
   system "$Command '$path'";

   # Return success code 1 to caller:
   return 1;
} # end sub curfile

sub stats {
   # Print stats if being terse or verbose:
   if ( $Verbose >= 1 ) {
      say STDERR "\nStats for running \"$pname\" on directory tree \"$OriDir\"";
      say STDERR "using target \"$Target\", regexp \"$RegExp\", and predicate \"$Predicate\":";
      say STDERR "Navigated $direcount directories and applied command \"$Command\"";
      say STDERR "to $filecount files matching given target, regexp, and predicate.";
   }
   return 1;
} # end sub stats

sub error ($NA) {
   print STDERR ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: You typed $NA arguments, but this program takes 1, 2, or 3 arguments.
   Argument 1 (mandatory) is a command to be executed on each file.
   Argument 2 (optional)  is a regular expression indicating which files.
   Argument 3 (optional)  is a boolean predicate using Perl file-test operators.
   Help follows:
   END_OF_ERROR
} # end sub error

sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "for-each-file.pl", Robbie Hatley's nifty program for applying
   a command to each file in the current directory (and all subdirectories if
   a -r or --recurse option is used).

   Command lines:

   To just print this help and exit:
   for-each-file.pl [-h|--help]

   To apply a command to every file:
   for-each-file.pl [options] command [regexp] [predicate]

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

   In addition to options, "for-each-file.pl" takes 1, 2, or 3 arguments:

   Argument 1 (mandatory) is a command to be executed on each file. The following
   command will be sent to the shell for each file being processed, where "command"
   is the first argument to this program, and "path" is the path of each file:

      command 'path'

   The command can be any valid command that could be executed on a command line.
   Be sure to enclose your command in 'single quotes', else your shell may execute
   the command, whereas this program needs the raw command string sent to it.
   For example, to print the contents of all files, you could use:

      for-each-file.pl 'cat'

   Argument 2 (optional), if present, must be a Perl-Compliant Regular Expression
   specifying which items to process. To specify multiple patterns, use the |
   alternation operator. To apply pattern modifier letters, use an Extended
   RegExp Sequence. For example, if you want to print the contents of any files
   with names containing "cat", "dog", or "horse", title-cased or not, you could
   use this command line:

      for-each-file.pl 'cat' '(?i:c)at|(?i:d)og|(?i:h)orse'

   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   Argument 3 (optional), if present, must be a boolean predicate using Perl
   file-test operators. The expression must be enclosed in parentheses (else
   this program will confuse your file-test operators for options), and then
   enclosed in single quotes (else the shell won't pass your expression to this
   program intact). If this argument is used, it overrides "--files", "--dirs",
   or "--both", and sets target to "--all" in order to avoid conflicts with
   the predicate. Here are some examples of valid and invalid predicate arguments:
   '(-d && -l)'  # VALID:   Finds symbolic links to directories
   '(-l && !-d)' # VALID:   Finds symbolic links to non-directories
   '(-b)'        # VALID:   Finds block special files
   '(-c)'        # VALID:   Finds character special files
   '(-S || -p)'  # VALID:   Finds sockets and pipes.  (S must be CAPITAL S   )
    '-d && -l'   # INVALID: missing parentheses       (confuses program      )
    (-d && -l)   # INVALID: missing quotes            (confuses shell        )
     -d && -l    # INVALID: missing parens AND quotes (confuses prgrm & shell)

   Arguments and options may be freely mixed, but the arguments must appear in
   the order Arg1, Arg2, Arg3 (Command, RegExp, Predicate). If you use them in
   the wrong order, they won't do what you want.

   A number of arguments less-than-1 or greater-than-3 will cause this program
   to print an error message and abort.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
