#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# enumerate-file-names.pl
# Adds a "numerator" of the form "-(####)" (where # means "random digit") at end of the prefix of the name of
# every file in the current working directory (and all of its subdirectories if a "-r" or "--recurse" option
# is used). This helps with the aggregation and de-duping of files with the same name prefix and possibly
# the same content.
#
# Also check-out the following programs, which are intended to be used in conjunction with this program:
# "dedup-files.pl"
# "dedup-newsbin-files.pl"
# "denumerate-file-names.pl"
#
# Author: Robbie Hatley.
#
# Edit history:
# Mon Apr 27, 2015: Wrote first draft. Kinda skeletal at this point. Stub.
# Thu Apr 30, 2015: Made many additions and changes. Now fully functional.
# Mon Jul 06, 2015: Corrected some minor errors.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Mon Dec 25, 2017: Added and corrected comments.
# Mon Feb 24, 2020: Changed width to 110 and added entry, stats, and exit announcements.
# Tue Jan 19, 2021: Heavily refactored. Got rid of all global vars, now using prototypes, etc.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Sat Dec 04, 2021: Now using regexp instead of wildcard.
# Wed Mar 15, 2023: Added options for local, recursive, quiet, and verbose.
# Sat Aug 19, 2023: Upgraded from "v5.32" to "v5.36". Reduced width from 120 to 110. Got rid of CPAN module
#                   "common::sense" (antiquated). Got rid of all prototypes. Now using signatures.
# Sun Aug 20, 2023: Now printing diagnostics, errors, and stats to STDERR, but everything else to STDOUT.
# Mon Aug 21, 2023: Increased parallelism between "denumerate-file-names.pl" and "enumerate-file-names.pl".
# Mon Aug 21, 2023: An "option" is now "one or two hyphens followed by 1-or-more word characters".
#                   Reformatted debug printing of opts and args to ("word1", "word2", "word3") style.
#                   Inserted text into help explaining the use of "--" as "end of options" marker.
# Mon Aug 28, 2023: Clarified sub argv().
#                   Got rid of "/...|.../" in favor of "/.../ || /.../" (speeds-up program).
#                   Simplified way in which options and arguments are printed if debugging.
#                   Removed "$" = ', '" and "$, = ', '". Got rid of "/o" from all instances of qr().
#                   Changed all "$db" to $Debug". Debugging now simulates renames instead of exiting in main.
#                   Removed "no debug" option as that's already default in all of my programs.
#                   Changed short option for debugging from "-e" to "-d".
# Wed Aug 14, 2024: Removed unnecessary "use" statements. Changed short option for debug from "-d" to "-e".
# Tue Mar 04, 2025: Now using global "t0" and "BEGIN" block to start timer.
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e".
# Tue May 06, 2025: Reverted to "-C63", "utf8", "Cwd", "d", "e", for Cygwin compatibility.
#                   Modernized, importing much content from latest "core-utils.pl".
##############################################################################################################

use v5.36;
use utf8;
use Cwd;
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
my $Target    = 'F'       ; # Target                    F|D|B|A   Target files only.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.
my $OriDir    = d(getcwd) ; # Original directory.       cwd       Directory on program entry.
my $Hidden    = 0         ; # Process hidden files?     bool      Don't touch hidden files!
my $Bypass    = 0         ; # Bypass enumerated files?  bool      Don't bypass anything.

# Counters:
my $direcount = 0         ; # Count of directories navigated.
my $filecount = 0         ; # Count of files matching target, regexp, and predicate.
my $bypacount = 0         ; # Count of files bypassed.
my $skipcount = 0         ; # Count of files skipped.
my $attecount = 0         ; # Count of file renames attempted.
my $succcount = 0         ; # Count of file renames succeeded.
my $failcount = 0         ; # Count of file renames failed.
my $simucount = 0         ; # Count of file renames simulated.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

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
       ."Hidden    = $Hidden    \n"
       ."Bypass    = $Bypass    \n"
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
      say STDERR "Hidden    = $Hidden";
      say STDERR "Bypass    = $Bypass";
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
      /^-$s*e/ || /^--debug$/   and $Debug      =  1  ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0  ; # Default.
      /^-$s*t/ || /^--terse$/   and $Verbose =  1  ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2  ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0  ; # Default.
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1  ;
      /^-$s*f/ || /^--files$/   and $Target  = 'F' ;
      /^-$s*d/ || /^--dirs$/    and $Target  = 'D' ;
      /^-$s*b/ || /^--both$/    and $Target  = 'B' ;
      /^-$s*a/ || /^--all$/     and $Target  = 'A' ; # Default.
      /^-$s*i/ || /^--hidden$/  and $Hidden  =  1  ;
      /^-$s*y/ || /^--bypass$/  and $Bypass  =  1  ;
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

   # Announce current working directory:
   say STDOUT '';
   say STDOUT "Directory # $direcount: $cwd";

   # Get list of file names in $cwd matching $Target, $RegExp, and $Predicate:
   my @names = readdir_regexp_utf8($cwd, $Target, $RegExp, $Predicate);

   # Iterate through @names and send each non-hidden name to curfile():
   foreach my $name ( @names ) {
      BLAT "Debug msg in efn, in curdire, in foreach: \$name = $name";
      next if ! $Hidden && $name =~ m/^\./;
      curfile($name);
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($name) {
   # Increment file counter:
   ++$filecount;

   # Bypass this file if it is numerated and $Bypass is set:
   if ( get_prefix($name) =~ m/-\(\d\d\d\d\)$/ && $Bypass ) {
      ++$bypacount;
      return 1;
   }

   # Set $newname to a  enumerated version of $name:
   my $newname = find_avail_enum_name($name);

   # Skip this file if no suitable new name was available (only happens if nearly 10,000 copies exist):
   if ( $newname eq '***ERROR***' ) {
      say STDOUT '';
      say STDOUT "Can't  enumerate \"$name\" because no available name could be found.";
      ++$skipcount;
      return 1;
   }

   # If debugging, simulate rename then return without attempting any actual rename:
   if ( $Debug ) {
      ++$simucount;
      say STDOUT '';
      say STDOUT "File rename simulation #$simucount:";
      say STDOUT "Old name: $name";
      say STDOUT "New name: $newname";
      return 1;
   }

   # Otherwise, attempt to rename the file from $name to $newname:
   else {
      ++$attecount;
      say STDOUT '';
      say STDOUT "File rename attempt #$attecount:";
      say STDOUT "Old name: $name";
      say STDOUT "New name: $newname";
      if ( rename_file($name, $newname) ) {
         ++$succcount;
         say STDOUT "File successfully renamed!";
         return 1;
      }
      else {
         ++$failcount;
         say STDOUT "File rename failed!";
         return 0;
      }
   }
} # end sub curfile ($file)

# Print messages only if debugging:
sub BLAT ($string) {if ($Debug) {say STDERR $string}}

# Print statistics for this program run:
sub stats {
   if ( $Verbose >= 1 ) {
      say    STDERR '';
      say    STDERR 'Statistics for program "enumerate-file-names.pl":';
      printf STDERR "Traversed   %6u directories.           \n", $direcount;
      printf STDERR "Found       %6u files matching RegExp. \n", $filecount;
      printf STDERR "Bypassed    %6u numerated files.       \n", $bypacount;
      printf STDERR "Skipped     %6u unenumerable files     \n", $skipcount;
      printf STDERR "Attempted   %6u file renames.          \n", $attecount;
      printf STDERR "Enumerated  %6u files.                 \n", $succcount;
      printf STDERR "Failed      %6u file rename attempts.  \n", $failcount;
      printf STDERR "Simulated   %6u file renames.          \n", $simucount;
   }
   return 1;
} # end sub stats

# Handle errors:
sub error ($NA)
{
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most 1 argument,
   which, if present, must be a Perl-Compliant Regular Expression specifying
   which files to enumerate. Help follows:
   END_OF_ERROR
} # end sub error ($NA)

# Print help:
sub help
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to EnumerateFileNames, Robbie Hatley's file-enumerating script. This
   program tacks "numerators" of the form "-(####)" (where "#" is any digit)
   to the ends of the prefixes of all regular files in the current working
   directory (and all of its subdirectories if a -r or --recurse option is used).

   By default, this program processes regular files only, but other types of items
   can be processed by using an appropriate target option (see options below) or
   by using an appropriate predicate argument (see arguments below).

   By default, this program skips all hidden files, but hidden files can be
   processed by using a "-i" or "--hidden" option.

   -------------------------------------------------------------------------------
   Command Lines:

   enumerate-file-names.pl  [-h|--help]        (to print this help and exit)
   enumerate-file-names.pl  [options] [Arg1]   (to enumerate file names)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.
   -e or --debug      Print diagnostics and simulate renames.
   -q or --quiet      Be quiet.
   -t or --terse      Be terse.                               (DEFAULT)
   -v or --verbose    Be verbose.
   -l or --local      DON'T recurse subdirectories.           (DEFAULT)
   -r or --recurse    DO    recurse subdirectories.
   -f or --files      Target Files.                           (DEFAULT)
   -d or --dirs       Target Directories.
   -b or --both       Target Both.
   -a or --all        Target All.
   -i or --hidden     Also process hidden files.
   -y or --bypass     Bypass already-numerated files.
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

   A number of arguments greater than 2 will cause this program to print an error
   message and abort.

   Happy file enumerating!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
