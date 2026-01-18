#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# /rhe/scripts/util/census.pl
# Robbie Hatley's nifty file-system census utility. Prints how many files and bytes are in the current
# directory and each of its subdirectories.
# Written by Robbie Hatley.
# Edit history:
# Fri May 08, 2015: Wrote first draft.
# Thu Jul 09, 2015: Various minor improvements.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Sun Sep 20, 2020: Corrected errors in Help.
# Mon Sep 21, 2020: Corrected more errors in Help, increased width to 97, changed "--atleast="
#                   to "--files=", added "--gb=", improved comments and formatting, and now
#                   ANDing "--gb=" and "--files=" together.
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory as
#                   its first argument, target as second, and regexp (instead of wildcard) as third.
# Wed Nov 17, 2021: Added "use common::sense;", shortened sub names, added comments, corrected errors in help,
#                   wrapped regexp in qr//, refactored argv(), added sub dirstats(), and unscrambled the logic
#                   in curdire().
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Mon Sep 04, 2023: Upgraded from "v5.32" to "v5.36". Got rid of "common::sense" (antiquated). Got rid of all
#                   prototypes. Now using signatures. Reduced width from 120 to 110. Removed '/o' from all
#                   qr(). Added debug, quiet, verbose, local, recurse options. Entry/stats/exit messages are
#                   now printed only if being verbose. Entry/stats/exit are to STDERR and header and dir info
#                   are to STDOUT. $direcount, $filecount, and $gigacount now count only directories and files
#                   which obey the restrictions imposed by $RegExp, $Empty, $GB, and $Files. Improved help.
# Wed Aug 14, 2024: Removed unnecessary "use" statements.
# Tue Mar 04, 2025: Added comments to subroutine predeclarations.
# Fri May 02, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e".
# Tue May 06, 2025: Reverted to "-C63", "utf8", "Cwd", "d", "e", for Cygwin compatibility.
# Fri Dec 26, 2025: Re-reverted to "#!/usr/bin/env perl", "use utf8::all", "use Cwd::utf8".
#                   Moved from "core" to "util". Deleted "core".
# Sun Jan 18, 2026: Added provision for checking if $OriDir is actually valid (because I've seen that in some
#                   edge cases it may not be!); now also doing RH::Dir debugging if doing local debugging.
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

# Settings:     Default:      Meaning of setting:               Range:        Meaning of default:
my @Opts      = ()        ; # options                           array         Options.
my @Args      = ()        ; # arguments                         array         Arguments.
my $Debug     = 0         ; # Debug?                            bool          Don't debug.
my $Help      = 0         ; # Just print help and exit?         bool          Don't print-help-and-exit.
my $Verbose   = 0         ; # Print entry/stats/exist msgs?     bool          Don't print the messages.
my $Recurse   = 0         ; # Recurse subdirectories?           bool          Don't recurse.
my $OriDir    = cwd       ; # Original directory.               cwd           Cwd on program entry.
my $RegExp    = qr/^.+$/o ; # Regular expression.               regexp        Process all file names.
my $Predicate = 1         ; # Boolean predicate.                bool          Process all file types.
my $Empty     = 0         ; # Show only empty directories?      bool          Show empty AND non-empty.
my $GB        = 0.0       ; # Show only dirs w >= $GB GB.       non-neg real  Show dirs of all sizes.
my $Files     = 0         ; # Show only dirs w >= $Files files  non-neg int   Show dirs of all file counts.

# NOTE: There is no "$Target" in this program, because we're only interested in files that use storage space.
# Those are files obeying file-test-operator predicate "-f _ && !-d _ && !-l _". That still allows any of
# -b -c -p -S -t to be true, but that's OK, because "weird" files can still take-up storage space, and we
# are interested in tallying ALL files ("weird" or not) that take-up storage space.

# Counters:
my $direcount = 0; # Count of directories processed.
my $filecount = 0; # Count of files       processed.
my $gigacount = 0; # Count of gigabytes   processed.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub dstats  ; # Print directory statistics.
sub tstats  ; # Print tree statistics.
sub error   ; # Handle errors.
sub help    ; # Print help.

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
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR "Minimum dir size  = ${GB}GB."      ;
      say STDERR "Minimum dir files = $Files files." ;
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
      say STDERR "Recurse   = $Recurse";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR "Empty     = $Empty";
      say STDERR "GB        = $GB";
      say STDERR "Files     = $Files";
      say STDERR "OriDir    = $OriDir";
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
         tstats;
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
      printf STDERR "\nNow exiting program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n",
                    $s1[2], $s1[1], $s1[0], 1+$s1[4], $s1[3], 1900+$s1[5];
      printf STDERR "Execution time was %.3fms.\n", $ms;
   }

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end MAIN

# ======= SUBROUTINE DEFINITIONS =============================================================================

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
      /^-$s*h/ || /^--help$/    and help and exit 777 ;
      /^-$s*d/ || /^--debug$/   and $Debug   =  1     ; # Default is 0.
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0     ; # Default is 0.
      /^-$s*t/ || /^--terse$/   and $Verbose =  1     ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2     ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0     ; # Default is 0.
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1     ;
      /^-$s*e/ || /^--empty$/   and $Empty   =  1     ; # Default is 0.
      /^--gb=(\d+\.?\d*)$/      and $GB      = $1     ; # Default is 0.0.
      /^--files=(\d+)$/         and $Files   = $1     ;
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
   # Get current working directory:
   my $cwd = cwd;

   # Get ref to array of refs to hashes of info on all regular files in current working directory which match
   # given regexp and predicate:
   my $curdirfiles = GetFiles($cwd, 'F', $RegExp, $Predicate);
   # Note: these files might also be b,c,p,S,t, but those can take-up space also, and we're interested in
   # tallying ALL storage space used, including storage space used by weird files.

   # Tally all bytes of data stored in files in current directory:
   my $bytes = 0;
   foreach my $file (@$curdirfiles) {$bytes += $file->{Size}}
   my $gigabytes = $bytes/1000000000.0;

   # If in "show empties only" mode,
   # then only print directories which contain zero regular files:
   if ($Empty) {
      if ( 0 == $RH::Dir::totfcount ) {
         ++$direcount;
         $filecount += $RH::Dir::totfcount;
         $gigacount += $gigabytes;
         printf STDOUT "%7d Files %9.3fGB: %s\n", $RH::Dir::totfcount, $gigabytes, $cwd;
      }
      else {
         ; # Do nothing.
      }
   }

   # Otherwise, we're NOT in "show empties only" mode, so display info for this directory
   # if it contains at-least $Files files AND at-least $GB gigabytes of data.
   # (NOTE: One may be forgiven for thinking that I'd OR together the $GB and $Files predicates, but no, we
   # need to AND them together instead. If you think about it, you'll see why: the defaults already allow all
   # files, so if we OR the restrictions, then neither $GB nor $Files will have any effect at all, because the
   # OTHER restriction will still be at max laxness. So we need to AND them instead; that way, the two
   # restrictions can be used either independently or together.)
   else {
      if ($RH::Dir::totfcount >= $Files && $gigabytes >= $GB) {
         ++$direcount;
         $filecount += $RH::Dir::totfcount;
         $gigacount += $gigabytes;
         printf STDOUT "%7d Files %9.3fGB: %s\n", $RH::Dir::totfcount, $gigabytes, $cwd;
      }
      else {
         ; # Do nothing.
      }
   }
   return 1;
} # end sub curdire

sub tstats {
   say STDERR '';
   say STDERR "Found $direcount directories matching given limits.";
   say STDERR "Those directories contain $filecount regular files";
   say STDERR "and take-up $gigacount GB of storage space.";
   return 1;
} # end sub tstats

sub error ($NA) {
   print ((<<'   END_OF_ERROR') =~ s/^   //gmr);

   Error: You typed $NA arguments, but Census takes at most 1 argument,
   which, if present, must be a Perl-Compliant Regular Expression specifying
   which files to tally sizes for. Help follows:
   END_OF_ERROR
   help;
   return 1;
} # end sub error

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "census.pl", Robbie Hatley's nifty directory-tree census utility.
   This program prints how many files are in the current directory and each of its
   subdirectories, and how many gigabytes of storage space they use.

   -------------------------------------------------------------------------------
   Command lines:

   census.pl -h | --help        (to print this help and exit)
   census.pl [options] [Arg]    (to tally files & gigabytes in directories)

   -------------------------------------------------------------------------------
   Description of options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -d or --debug      Print diagnostics.
   -q or --quiet      Don't print     entry/exit/stats messages.         (DEFAULT)
   -t or --terse      Print limited   entry/exit/stats messages.
   -v or --verbose    Prtnt exuberant entry/exit/stats messages.
   -l or --local      Don't recurse subdirectories.                      (DEFAULT)
   -r or --recurse    Do    recurse subdirectories.
   -e or --empty      Only display directories containing 0 regular files.
   --files=####       Only display directories containing at least ####
                      files, where #### is any non-negative integer.
   --gb=##            Only display directories containing at least ##
                      gigabytes, where ## is any non-negative integer.
         --           End of options (all further CL items are arguments).

   "-e" overrides "gb=" and/or "files=" and prints info ONLY on directories
   which are empty.

   If both "--gb=" and "--files=" are BOTH used, they are logically ANDed
   together. So if you command "census.pl --gb=1.3 --files=500", then
   census.pl will print info on any directories which contain both
   1.3GB-or-more of content AND 500+ files.

   If "-e|--empty", "--gb=", or "--files=" are NOT used, then this program prints
   info on ALL directories in the directory tree descending from the cwd.

   Multiple single-letter options may be piled-up after a single hyphen. For
   example, use -dl to print diagnostics and process the current directory
   only.

   If you want to use an argument that looks like an option (say, you want to
   process only files which contain "--recurse" as part of their name), use a "--"
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

   Happy directory storage-space-usage reporting!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
