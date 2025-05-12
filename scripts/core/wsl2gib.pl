#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# wsl2gib.pl
# Renames each file in the current directory (and all subdirectories if a -r or --recurse option is used)
# which has a 64-character "Windows Spotlight"-style file name to a name consisting of 8 random lower-case
# letters followed by the original file name extension.
#
# Edit history:
# Fri Oct 23, 2020: Wrote it.
# Mon Dec 21, 2020: Now also has recursion available.
# Sun Jan 03, 2021: Now also processes many other file types besides just jpg.
# Mon Feb 15, 2021: Dramatically simplied. File names can now have any extension or none.
#                   Renamed to "wsl-to-gib.pl". [Note, 2023-08-08: From what, I wonder?]
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Tue Aug 08, 2023: Upgraded from "v5.32" to "v5.36". Renamed from "wsl-to-gib.pl" to "wsl2gib.pl".
#                   Reduced width from 120 to 110.
# Sat Apr 05, 2025: Now using "Cwd::utf8"; nixed "cwd_utf8".
# Wed May 07, 2025: Reverted to "-C63", "utf8", "Cwd", "d", "e", for Cygwin compatibility.
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
my $Target    = 'A'       ; # Target                    F|D|B|A   Target all directory entries.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.
my $OriDir    = d(getcwd) ; # Original directory.       cwd       Directory on program entry.

# Counters:
my $direcount = 0         ; # Count of directories processed by curdire().
my $filecount = 0         ; # Count of files matching target, regexp, and predicate.
my $renacount = 0         ; # Count of files renamed.
my $failcount = 0         ; # Count of failed file-rename attempts.

# Windows SpotLight file-name pattern:
my $wslpat = qr(^[0-9a-z]{64}(?:-\(\d{4}\))?(?:\.[a-zA-Z]+)?$);

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

   # Get sorted list of names in $cwd matching $Target, $RegExp, and $Predicate:
   my @names = sort {$a cmp $b} readdir_regexp_utf8($cwd, $Target, $RegExp, $Predicate);

   # Send the path of each file with a WSL name to curfile():
   foreach my $name (@names) {
      if ( $name =~ m/$wslpat/ ) {
         curfile(path($cwd, $name));
      }
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($path) {
   ++$filecount;
   my $name     = get_name_from_path($path);
   my $dir      = get_dir_from_path($path);
   my $suff     = get_suffix($name);
   my $new_name = find_avail_rand_name($dir, '', $suff);
   $new_name eq '***ERROR***'
   and ++$failcount
   and warn "Unable to find available random name for \"$path\".\n"
   and return 0;
   rename_file($name, $new_name)
   and ++$renacount
   and say "Renamed \"$name\" to \"$new_name\""
   and return 1
   or  ++$failcount
   and warn "FAILED to rename \"$name\" to \"$new_name\"\n"
   and return 0;
} # end sub curfile ($path)

# Print messages only if debugging:
sub BLAT ($string) {if ($Debug) {say STDERR $string}}

# Print statistics for this program run:
sub stats {
   print("\nStats for \"wsl2gib.pl\":\n");
   printf("Navigated %6u directories.\n",           $direcount);
   printf("Found     %6u files with wsl names.\n",  $filecount);
   printf("Renamed   %6u files.\n",                 $renacount);
   printf("Failed    %6u file-rename attempts.\n",  $failcount);
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
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "$pname". This program renames all regular files in the
   current directory (and all subdirectories if a -r or --recurse option is used)
   which have 64-character Windows-Spotlight-style file names
   to names consisting of 8 lower case letters
   followed by the file name extension of the original file.

   -------------------------------------------------------------------------------
   Command lines:

   $pname -h | --help             (to print this help and exit)
   $pname [options] [arguments]   (to convert file names from wsl to gib)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.
   -e or --debug      Print diagnostics.
   -q or --quiet      Be quiet.
   -t or --terse      Be terse.                         (DEFAULT)
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

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
