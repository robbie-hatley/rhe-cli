#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# core-template.pl
# This file serves as a template for making new "core" (Cygwin-compatible) file and directory maintenance
# scripts, NOT dependent on "utf8::all" or "Cwd::utf8". (See "util" for ancillary scripts intended for use
# on Linux only. Those scripts are based on "utf8::all" and "Cwd::utf8", which makes writing and maintaining
# them much easier, at the cost of NOT being compatible with Cygwin.)
#
# Edit history:
# Mon May 04, 2015: Wrote first draft.
# Wed May 13, 2015: Updated and changed Help to "Here Document" format.
# Thu Jun 11, 2015: Corrected a few minor issues.
# Tue Jul 07, 2015: Now fully utf8 compliant.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Sun Dec 24, 2017: Now splicing options from @ARGV.
# Thu Jul 11, 2019: Combined getting & processing options and arguments.
# Fri Jul 19, 2019: Renamed "get_and_options_and_arguments" to "argv" and got rid of arrays @CLOptions and
#                   @CLArguments.
# Sun Feb 23, 2020: Added entry and exit announcements, and refactored statistics.
# Sat Jan 02, 2021: Got rid of all "our" variables; all subs return 1; and all Here documents are now
#                   indented 3 spaces.
# Fri Jan 29, 2021: Corrected minor comment and formatting errors, and changed erasure of Here-document
#                   indents from "s/^ +//gmr" to "s/^   //gmr".
# Mon Feb 08, 2021: Got rid of "help" function (now using "__DATA__"). Renamed "error" to "error".
# Sat Feb 13, 2021: Reinstituted "help()". "error()" now exits program. Created "dire_stats()".
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory as
#                   its first argument, target as second, and regexp (instead of wildcard) as third.
# Mon Mar 15, 2021: Now using time stamping.
# Sat Nov 13, 2021: Refreshed colophon, title card, and boilerplate.
# Mon Nov 15, 2021: Changed regexps to qr/YourRegexpHere/, and instructed user to use "extended regexp
#                   sequences" in order to use pattern modifiers such as "i".
# Tue Nov 16, 2021: Now using common::sense, and now using extended regexp sequences instead of regexp
#                   delimiters.
# Wed Nov 17, 2021: Now using raw regexps instead of qr//. Also, fixed bug in which some files were being
#                   reported twice because they matched more than one regexp. (I inverted the order of the
#                   regexp and file loops.)
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Fri Dec 03, 2021: Now using just 1 regexp. (Use alternation instead of multiple regexps.)
# Sat Dec 04, 2021: Improved formatting in some places.
# Sun Mar 05, 2023: Updated to v5.36. Got rid of "common::sense" (antiquated). Got rid of "given" (obsolete).
#                   Changed all prototypes to conform to v5.36 standards:
#                   "sub mysub :prototype($) {my $x=shift;}"
# Sat Mar 18, 2023: Added missing "use utf8" (necessary due to removal of common::sense). Got rid of all
#                   prototypes. Converted &curfile and &error to signatures. Made &error a "do one thing only"
#                   subroutine. Added "quiet", "verbose", "local", and "recurse" options.
# Tue Jul 25, 2023: Decreased width to 110 (with github in mind). Made single-letter options stackable.
# Mon Jul 31, 2023: Cleaned up formatting and comments. Fine-tuned definitions of "option" and "argument".
#                   Fixed bug in which $, was being set instead of $" .
#                   Got rid of "--target=xxxx" options in favor of just "--xxxx".
# Sat Aug 05, 2023: Command-line item "--" now means "all further items are arguments, not options".
# Sun Aug 06, 2023: Improvements to argv, error, and help. Added $Predicate.
# Sat Aug 12, 2023: Fixed wrong width in colophon.
# Mon Aug 21, 2023: An "option" is now "one or two hyphens followed by 1-or-more word characters".
#                   Reformatted debug printing of opts and args to ("word1", "word2", "word3") style.
#                   Inserted text into help explaining the use of "--" as "end of options" marker.
# Thu Aug 24, 2023: Redefined what characters may exist in options:
#                   short option = 1 hyphen , NOT followed by a hyphen, followed by [a-zA-Z0-9]+
#                   long  option = 2 hyphens, NOT followed by a hyphen, followed by [a-zA-Z0-9-=.]+
#                   I use negative look-aheads to check for "NOT followed by a hyphen".
#                   Got rid of "o" option on qr// (unnecessary). Put "\$" before variable names to be printed.
#                   Removed code that exits after printing settings if debugging. Inserted code that puts
#                   program in "simulate" mode near bottom of curfile() if debugging. Fixed bug in which "-"
#                   was being interpretted as "character range" instead of "hyphen", by changing
#                   "$d = [a-zA-Z0-9-=.]+" to "$d = [a-zA-Z0-9=.-]+". Added "nodebug" option. Fixed bug in
#                   which curfile was never being called.
# Mon Aug 28, 2023: Clarified sub argv().
#                   Got rid of "/...|.../" in favor of "/.../ || /.../" (speeds-up program).
#                   Simplified way in which options and arguments are printed if debugging.
#                   Removed "$" = ', '" and "$, = ', '". Got rid of "/o" from all instances of qr().
#                   Changed all "$db" to $Debug". Debugging now simulates renames instead of exiting in main.
#                   Removed "no debug" option as that's already default in all of my programs.
# Fri Sep 01, 2023: Entry & exit messages are now printed regardless, to STDERR.
#                   STDERR = entry & exit messages, stats, diagnostics, and severe errors.
#                   STDOUT = directories ("Dir # 27: Dogs") and files ("Successfully renamed asdf to yuio").
#                   Stats also go to STDERR, but are controlled by verbosity level (0=none, 1=some, 2=all).
# Sat Mar 23, 2024: I'm leaving the V # set to 5.36 even though the latest is 5.38, because 5.36 is the first
#                   version to include "signatures", and Cygwin takes a while to catch up to Linux. I've also
#                   removed "Sys::Binmode" because as long as one always encodes outbound and decodes inbound,
#                   it does nothing. Also corrected comments for "$filecount" to include mention of target.
#                   Also added a comment for the "for(@ARGV)" loop in sub "argv".
# Thu Aug 15, 2024: -C63; got rid of unnecessary "use" statements.
# Fri Feb 14, 2025: Got rid of Sys::Binmode and made other minor tweaks.
# Tue Feb 18, 2025: Added timestamps to program entry and exit messages; decoupled debug, verbosity, and help;
#                   consolidated debug variable printing; consolidated recursion, stats, and help on one line;
#                   made "@Opts"and "@Args" file-lexical; and "--" is now stored in "@Opts". I incorporated
#                   many bits of tech from "age.pl", but I decided to keep "extra arguments" a fatal error
#                   (instead of just a warning as in "age.pl"), because this template may be used to make
#                   programs which are more dangerous than "age.pl" is.
# Tue Mar 04, 2025: Got rid of prototypes and empty sigs. Added comments to subroutine predeclarations.
#                   Now using "BEGIN" and "END" blocks to print entry and exit messages.
# Sun Mar 09, 2025: Got rid of all BEGIN and END blocks, as they're too unreliable in their variable access.
# Wed Mar 12, 2025: Now using BEGIN blocks the CORRECT way, to initialize global variables $pname,
#                   $cmpl_beg, and $cmpl_end. Also renamed "$Debug" to "$Debug".
# Fri Apr 04, 2025: Now using "utf8::all" and "Cwd::utf8". Nixed "*_utf8", "d", "e". Simplified shebang to
#                   "#!/usr/bin/env perl".
# Wed Apr 09, 2025: Got rid of "use warnings FATAL => 'utf8'", as that's subsumed into "use utf8::all".
# Mon May 05, 2025: Split "Template.pl" into "util/util-template.pl" (dependent on "utf8::all" and "Cwd::utf8"
#                   and NOT compatible with Cygwin) and "core/core-template.pl" (NOT dependent on "utf8::all"
#                   or "Cwd::utf8" and hence Cygwin compatible).
##############################################################################################################

##############################################################################################################
# myprog.pl
# Twiddles libokods on ungish iblkaubs.
# Written by Robbie Hatley.
# Edit history:
# Tue Jul 01, 2025: Wrote it.
##############################################################################################################

# Pragmas:
use v5.36;

# Essential CPAN Modules:
use utf8;
use Cwd;
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

   # Send each path to curfile():
   foreach my $path (@paths) {curfile($path)}

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($path) {
   # Increment file counter:
   ++$filecount;

   # Announce path:
   if ( $Debug >= 1 ) {
      say STDOUT "Simulate: $path";
      # (Don't actually DO anything to file at $path.)
   }
   else {
      say STDOUT "Activate: $path";
      # (Insert code here to DO something to file at $path.)
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curfile

# Print messages only if debugging:
sub BLAT ($string) {if ($Debug) {say STDERR $string}}

# Print statistics for this program run:
sub stats {
   # If being terse or verbose, print basic stats to STDERR:
   if ( $Verbose >= 1 ) {
      say STDERR '';
      say STDERR "Statistics for running script \"$pname\" on \"$OriDir\" directory tree";
      say STDERR "with target \"$Target\", regexp \"$RegExp\", and predicate \"$Predicate\":";
      say STDERR "Navigated $direcount directories.";
      say STDERR "Processed $filecount files matching given target, regexp, and predicate.";
   }
   return 1;
} # end sub stats

# Handle errors:
sub error ($NA) {
   print STDERR ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most
   2 arguments (an optional file-selection regexp and an optional
   file-selection predicate). Help follows.
   END_OF_ERROR
   return 1;
} # end sub error

# Print help:
sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

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

   A number of arguments less than 0 will likely rupture our spacetime manifold
   and destroy everything. But if you DO somehow manage to use a negative number
   of arguments without destroying the universe, please send me an email at
   "Hatley.Software@gmail.com", because I'd like to know how you did that!

   But if you somehow manage to use a number of arguments which is an irrational
   or complex number, please keep THAT to yourself. Some things would be better
   for my sanity for me not to know. I don't want to find myself enthralled to
   Cthulhu.


   Happy item processing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
