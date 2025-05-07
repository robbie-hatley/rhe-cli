#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# find-files.pl
# Finds directory entries in current directory (and all subdirectories if a -r or --recurse option is used)
# by providing a Perl-Compliant Regular Expression (PCRE) describing file names and/or by providing a boolean
# expression based on Perl file-test operators so that one can specify "regular files", "directories",
# "symbolic links to directories", "block special files", "sockets", etc, or any combination of those.
#
# This file used to be called "find-files-by-type.pl", but I realized that it also subsumes everything that
# my "find-files-by-name.pl" program does, so I'm retiring THAT program and renaming THIS one "find-files.pl".
#
# Written by Robbie Hatley.
#
# Edit history:
# Thu May 07, 2015: Wrote first draft.
# Mon May 11, 2015: Tidied some things up a bit, including using a
#                   "here" document to clean-up Help().
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Sun Dec 24, 2017: Splice options from @ARGV to @Options;
#                   added file type counters for use if being verbose.
# Tue Sep 22, 2020: Improved Help().
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory as
#                   its first argument, target as second, and regexp (instead of wildcard) as third.
# Tue Nov 16, 2021: Got rid of most boilerplate; now using "use common::sense" instead.
# Wed Nov 17, 2021: Now using "use Sys::Binmode". Also, fixed hidden bug which was causing program to fail to
#                   find any files with names using non-English letters. This was the "sending unencoded
#                   names to shell under Sys::Binmode" bug, which was previously hidden due to a compensating
#                   bug in Perl itself, which is removed by "Sys::Binmode". I fixed this by setting
#                   "local $_ = e file->{Path}" in sub "curfile".
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate, and now using "common::sense".
# Sat Nov 27, 2021: Shortened sub names. Tested: Works.
# Mon Feb 20, 2023: Upgraded to "v5.36". Got rid of prototypes. Put signatures on "curfile" and "error".
#                   Fixed the "$Quiet" vs "$Verbose" variable conflict. Improved "argv". Improved "help".
#                   Put 'use feature "signatures";' after 'use common::sense;" to fix conflict between
#                   common::sense and signatures.
# Fri Jul 28, 2023: Reduced width from 120 to 110 for Github. Got rid of "common::sense" (antiquated).
#                   Multiple single-letter options can now be piled-up after a single hyphen.
# Sat Jul 29, 2023: Got rid of print-out of stats for directory entries encountered per-directory or per-tree,
#                   as that info isn't relevant to finding specific files. Set defaults to local and quiet.
# Mon Jul 31, 2023: Renamed this file from "find-files-by-type.pl" to "find-files.pl". Retired program
#                   "find-files-by-name.pl". Moved file-name regexp to first argument and moved file-type
#                   predicate to second argument. Corrected bug in regexps in argv() which was failing to
#                   correctly discern number of hyphens on left end of each element of @ARGV (I fixed that bug
#                   by specifying that single-hyphen options may contain letters only whereas double-hyphen
#                   options may contain letters, numbers, punctuations, and symbols). Cleaned-up formatting
#                   and comments. Fixed bug in which $, was being set instead of $" .
#                   Got rid of "--target=xxxx" options in favor of just "--xxxx".
#                   Added file-type counts back in and made $Verbose trinary.
# Tue Aug 01, 2023: Took file-type counts back OUT and reverted $Verbose back to binary. Just not necessary.
#                   Corrected "count of files matching predicate is NOT reported by stats" bug.
#                   Corrected error in help in which the order of Arg1 and Arg2 was presented backwards.
# Thu Aug 03, 2023: Improved help. Re-instated "$Target". Re-instated "--local" and "--quiet".
#                   Now using "$pname" for program name to clean-up main body of program.
# Tue Aug 15, 2023: Disabled "Filesys::Type": slow, buggy, and unnecessary.
# Mon Aug 21, 2023: An "option" is now "one or two hyphens followed by 1-or-more word characters".
#                   Reformatted debug printing of opts and args to ("word1", "word2", "word3") style.
#                   Inserted text into help explaining the use of "--" as "end of options" marker.
# Thu Aug 31, 2023: Clarified sub argv().
#                   Got rid of "/...|.../" in favor of "/.../ || /.../" (speeds-up program).
#                   Simplified way in which options and arguments are printed if debugging.
#                   Removed "$" = ', '" and "$, = ', '". Got rid of "/o" from all instances of qr().
#                   Changed all "$db" to $Db". Debugging now simulates renames instead of exiting in main.
#                   Removed "no debug" option as that's already default in all of my programs.
#                   $Verbose now means "print directories". Everything else is now printed regardless.
#                   STDERR = "stats and serious errors". STDOUT = "files found, and dirs if being verbose".
# Fri Sep 01, 2023: Got rid of $Db and -e and --debug (not necessary).
# Tue Sep 05, 2023: That was stupid. Added $Db, -e, --debug back in. Improved help. Changed default target
#                   from 'F' to 'A' so as not to conflict with predicates. Entry/stats/exit messages are
#                   now printed to STDERR only if $Verbose >= 1. Directory headings are printed to STDOUT
#                   only if $Verbose >= 2. Found paths are printed to STDOUT regardless of verbosity level.
# Wed Sep 06, 2023: Set default target back to 'F', and set predicate to override target and force it to 'A'.
# Mon Jul 22, 2024: Fixed minor typos in error() and help() functions.
# Thu Aug 15, 2024: -C63; got rid of unnecessary "use" statements.
# Wed Mar 19, 2025: Modernized. Now offers many more options. Can now pile-up single-letter options after a
#                   single hyphen. Can now use both regexps and predicates to select files to process.
#                   Shortened width from 120 to 110. Put "-C63" in shebang.
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e".
# Tue May 06, 2025: Reverted to "-C63", "utf8", "Cwd", "d", "e", for Cygwin compatibility.
##############################################################################################################

use v5.36;
use utf8;
use Cwd;
use Time::HiRes 'time';
use RH::Dir;
use RH::Util;

# ======= VARIABLES: =========================================================================================

# ------- System Variables: ----------------------------------------------------------------------------------

$" = ', ' ; # Quoted-array element separator = ", ".

# ------- Global Variables: ----------------------------------------------------------------------------------

# WARNING: Do NOT initialize global variables on their declaration line! That wipes-out changes made to them
#          by BEGIN, UNITCHECK, CHECK, and INIT blocks! Instead, initialize them in those blocks.
our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.
our    $cmpl_beg;                              # Declare compilation begin time.
BEGIN {$cmpl_beg = time}                       # Set     compilation begin time.
our    $cmpl_end;                              # Declare compilation end   time.
INIT  {$cmpl_end = time}                       # Set     compilation end   time.

# NOTE: Always remember, if using BEGIN blocks, only the declaration half of any "my|our $varname = value;"
# statement is executed before the begin blocks; the "= value;" part is executed AFTER all BEGIN blocks!!!
# So, THIS code:
#    my $dog = 'Spot';
#    BEGIN {defined $dog ? print("defined\n") : print("undefined\n");}
#    print("My dog's name is $dog.\n");
#    END   {print("$dog is a nice dog.\n");}
# Is the same as THIS code:
#    my $dog;
#    defined $dog ? print("defined\n") : print("undefined\n");
#    $dog = 'Spot';
#    print("My dog's name is $dog.\n");
#    print("$dog is a nice dog.\n");
# And EITHER of those code blocks will print:
#    undefined
#    My dog's name is Spot.
#    Spot is a nice dog.

# ------- Local variables: -----------------------------------------------------------------------------------

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 0         ; # Be verbose?               0,1,2     Shhh! Be quiet!
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $Target    = 'A'       ; # Target                    F|D|B|A   Target all directory entries.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.
my $OriDir    = d(getcwd) ; # Original directory.       cwd       Directory on program entry.

# Counters:
my $direcount = 0         ; # Count of directories processed by curdire().
my $filecount = 0         ; # Count of files matching target, regexp, and predicate.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

# NOTE: These alert the compiler that these names, when encountered (whether in subroutine definitions,
# BEGIN, CHECK, UNITCHECK, INIT, END, other subroutines, or in the main body of the program), are subroutines,
# so it needs to find, compile, and link their definitions:
sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub BLAT    ; # Print messages only if debugging.
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

   # If debugging, print the values of all variables except counters, after processing @ARGV:
   BLAT "Debug msg: Values of variables after running argv():\n"
       ."pname     = $pname     \n"
       ."cmpl_beg  = $cmpl_beg  \n"
       ."cmpl_end  = $cmpl_end  \n"
       ."Options   = (@Opts)    \n"
       ."Arguments = (@Args)    \n"
       ."Debug     = $Debug     \n"
       ."Help      = $Help      \n"
       ."Verbose   = $Verbose   \n"
       ."Recurse   = $Recurse   \n"
       ."Target    = $Target    \n"
       ."RegExp    = $RegExp    \n"
       ."Predicate = $Predicate \n"
       ."OriDir    = $OriDir    \n"
       .'';

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
      say STDERR 'Basic settings:';
      say STDERR "OriDir    = $OriDir";
      say STDERR "Recurse   = $Recurse";
      say STDERR "Target    = $Target";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR '';
   }

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   if ($Help) {help}
   else {
      if ($Recurse) {
         my $mlor = RecurseDirs {curdire};
         say "\nMaximum levels of recursion reached = $mlor";
      }
      else {curdire}
      stats
   }

   # Stop execution timer:
   my $t1 = time;
   my @s1 = localtime($t1);

   # Print exit message if being terse or verbose:
   if ( $Verbose >= 1 ) {
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

   # If user typed more than 2 arguments, and we're not debugging,
   # then print error and help messages and exit:
   if ( $NA >= 3 && !$Debug ) {  # If number of arguments >= 3 and we're not debugging,
      error($NA);                # print error message,
      help;                      # and print help message,
      exit 666;                  # and exit, returning The Number Of The Beast.
   }

   # First argument, if present, is a file-selection regexp:
   if ( $NA >= 1 ) {             # If number of arguments >= 1,
      $RegExp = qr/$Args[0]/o;   # set $RegExp to $Args[0].
   }

   # Second argument, if present, is a file-selection predicate:
   if ( $NA >= 2 ) {             # If number of arguments >= 2,
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
   my $cwd = d(getcwd);

   # Announce current working directory if being verbose:
   if ( $Verbose >= 2 ) {
      say STDERR "\nDirectory # $direcount: $cwd\n";
   }

   # Get sorted list of paths in $cwd matching $Target, $RegExp, and $Predicate:
   my @paths = sort {$a cmp $b} glob_regexp_utf8($cwd, $Target, $RegExp, $Predicate);

   # For each matching path, increment file counter and say path:
   foreach my $path (@paths) {++$filecount;say $path}

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Print messages only if debugging:
sub BLAT ($string) {if ($Debug) {say STDERR $string}}

# Print stats, if being terse or verbose:
sub stats {
   if ( $Verbose >= 1 ) {
      say STDERR "\n"
                ."Statistics for running program \"$pname\" on dir tree \"$OriDir\":\n"
                ."Navigated $direcount directories. Found $filecount files matching\n"
                ."target \"$Target\", regexp \"$RegExp\", and predicate \"$Predicate\".";
   }
   return 1;
} # end sub stats

# Handle errors:
sub error ($NA) {
   print STDERR ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but \"$pname\" takes at most
   2 arguments (an optional file-selection regexp and an optional
   file-selection predicate). Help follows.
   END_OF_ERROR
   return 1;
} # end sub error

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "find-files.pl", Robbie Hatley's excellent file-finding utility!
   By default, this program finds all directory entries in the current working
   directory which match a given file-name regular expression
   (defaulting to '^.+$' meaning "all files") and file-type predicate
   (defaulting to '1'    meaning "all files"), and prints their full paths.

   Item types may be restricted to "regular files", "directories", or "both"
   by using appropriate options (see "Options" section below) or by using a
   file-type predicate (see "Arguments" section below).

   All subdirectories of the current working directory my be searched by using a
   "-r" or "--recurse" option.

   If no options, no regexp, and no predicate are specified, this program prints
   the paths of all regular files in the current working directory, which probably
   isn't what you want ("ls" is better for that), so I suggest using options and
   arguments to specify which items you're looking for.

   -------------------------------------------------------------------------------
   Command lines:

   find-files.pl [-h|--help]               (to print help)
   find-files.pl [options] [Arg1] [Arg2]   (to find files)

   -------------------------------------------------------------------------------
   Description of options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics.
   -q or --quiet      Don't print stats or directories.   (DEFAULT)
   -t or --terse      Print stats but  not directories.
   -v or --verbose    Print both stats AND directories.
   -l or --local      Don't recurse subdirectories.       (DEFAULT)
   -r or --recurse    Do    recurse subdirectories.
   -f or --files      Target Files.
   -d or --dirs       Target Directories.
   -b or --both       Target Both.
   -a or --all        Target All.                         (DEFAULT)
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vrf to verbosely and recursively search for files.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single colon,
   the result is determined by this descending order of precedence: heabdfrlvq.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of arguments:

   "find-files.pl" takes 0, 1, or 2 arguments.

   Arg1 (OPTIONAL), if present, must be a Perl-Compliant Regular Expression
   specifying which file names to look for. To specify multiple patterns, use the
   | alternation operator. To apply pattern modifier letters, use an Extended
   RegExp Sequence. For example, if you want to search for items with names
   containing "cat", "dog", or "horse", title-cased or not, you could use this:
   '(?i:c)at|(?i:d)og|(?i:h)orse'
   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   Arg2 (OPTIONAL), if present, must be a boolean predicate using Perl
   file-test operators. The expression must be enclosed in parentheses (else
   this program will confuse your file-test operators for options), and then
   enclosed in single quotes (else the shell won't pass your expression to this
   program intact). If this argument is used, it overrides "--files", "--dirs",
   or "--both", and sets target to "--all" in order to avoid conflicts with
   the predicate.

   Here are some examples of valid and invalid predicate arguments:
   '(-d && -l)'   # VALID:   Finds symbolic links to directories
   '(-l && !-d)'  # VALID:   Finds symbolic links to non-directories
   '(-b)'         # VALID:   Finds block special files
   '(-c)'         # VALID:   Finds character special files
   '(-f&&(-M)<3)' # VALID:   Finds regular files modified less than 3 days ago.
   '(-f&&(-A)<3)' # VALID:   Finds regular files accessed less than 3 days ago.
   '(-f&&(-C)<3)' # VALID:   Finds regular files created  less than 3 days ago.
   '(-f&&(-s)>100000000)' # VALID: Finds regular files bigger than 100MB.
   '(-S || -p)'   # VALID:   Finds sockets and pipes.
    '-d && -l'    # INVALID: missing parentheses       (confuses program      )
    (-d && -l)    # INVALID: missing quotes            (confuses shell        )
     -d && -l     # INVALID: missing parens AND quotes (confuses prgrm & shell)

   Arguments and options may be freely mixed, but the arguments must appear in
   the order Arg1, Arg2 (RegExp first, then File-Type Predicate); if you get them
   backwards, they won't do what you want, as most predicates aren't valid regexps
   and vice-versa.

   If the number of arguments is not 0, 1, or 2, this program will print an
   error message and abort.

   -------------------------------------------------------------------------------
   Usage Examples:

   Example #1: The following would look for all sockets with names containing
   "pig" or "Pig", in the current directory and all subdirectories, and also print
   stats and directories:
   find-files.pl -arv '(?i:p)ig' '(-S)'

   Example #2: The following will find all block-special and character-special
   files in the current directory with names containing '435', and would print
   the paths and stats, but not directories:
   find-files.pl '435' '(-b || -c)'

   Example #3: The following will find all symbolic links in all subdirectories
   and print their paths, but won't print any entry or exit message, stats, or
   directory headings at all. Note that because this program uses "positional"
   arguments, the regexp argument can't be skipped, but it can be "bypassed" by
   setting it to '.+' meaning "some characters":
   find-files.pl -rq '.+' '(-l)'


   Happy file finding!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end help
