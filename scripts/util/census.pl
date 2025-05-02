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
##############################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv       ; # Process @ARGV.
sub curdire    ; # Process current directory.
sub dire_stats ; # Print directory statistics.
sub tree_stats ; # Print tree statistics.
sub error      ; # Handle errors.
sub help       ; # Print help.

# ======= LEXICAL VARIABLES: =================================================================================

# Settings:     Default:    # Meaning of setting:                   Range:        Meaning of default:
my $Db        = 0         ; # Print diagnostics?                    bool          Don't print diagnostics.
my $Verbose   = 0         ; # Print entry/stats/exist msgs?         bool          Don't print the messages.
my $Recurse   = 0         ; # Recurse subdirectories?               bool          Don't recurse.
my $RegExp    = qr/^.+$/o ; # Regular expression.                   regexp        Process all file names.
my $Empty     = 0         ; # Show only empty directories?          bool          Show empty AND non-empty.
my $GB        = 0.0       ; # Show only dirs with >= $GB GB?        non-neg real  Show dirs of all sizes.
my $Files     = 0         ; # Show only dirs with >= $Files files.  non-neg int   Show dirs of all file counts.

# NOTE: One may be forgiven for thinking that we'd OR together the $GB and $Files predicates, but no, we need
# to AND them together instead. If you think about it, you'll see why: the defaults already allow all files,
# so if we OR the restrictions, then neither $GB nor $Files will have any effect at all, because the OTHER
# restriction will still be at max laxness. So we need to AND them instead; that way, the two restrictions can
# be used either independently or together.

# NOTE: There are no $Target or $Predicate variables in this program, because we're interested only in
# regular files, because those are the files that are using all the storage space, and answering the question
# "What's using the storage space???" is what this program is all about.

# NOTE: When I say "regular files", I mean Perl file-test-operator predicate "-f _ && !-d _ && !-l _".
# That still allows any of -b -c -p -S -t to be true, but that's OK, because "weird" files can still take-up
# storage space, and we are interested in tallying ALL files ("weird" or not) that take-up storage space.

# Counters:
my $direcount = 0; # Count of directories processed.
my $filecount = 0; # Count of files       processed.
my $gigacount = 0; # Count of gigabytes   processed.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Set time and program variables:
   my $t0 = time;
   my $pname = substr $0, 1 + rindex $0, '/';

   # Process @ARGV:
   argv;

   # Print entry message if being terse or verbose:
   if ( $Verbose >= 1 ) {
      say STDERR '';
      say STDERR "Now entering program \"$pname\"."  ;
      say STDERR "\$Db      = $Db"                   ;
      say STDERR "\$Verbose = $Verbose"              ;
      say STDERR "\$Recurse = $Recurse"              ;
      say STDERR "\$RegExp  = $RegExp"               ;
      say STDERR "Minimum dir size  = ${GB}GB."      ;
      say STDERR "Minimum dir files = $Files files." ;
   }

   # Print header to STDOUT regardless of verbosity level:
   say STDOUT 'Storage space in GB used by each directory in this tree:';

   # Process current directory (and all subdirectories if recursing):
   $Recurse and RecurseDirs {curdire} or curdire;

   # Print stats:
   tree_stats;

   # Print exit message if being terse or verbose
   if ( $Verbose >= 1 ) {
      say    STDERR '';
      say    STDERR "Now exiting program \"$pname\".";
      printf STDERR "Execution time was %.3fms.", 1000 * (time - $t0);
   }

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end MAIN

# ======= SUBROUTINE DEFINITIONS =============================================================================

sub argv {
   # Get options and arguments:
   my @opts = ();            # options
   my @args = ();            # arguments
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {
      /^--$/ && !$end        # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1           # so if we see that, then set the "end-of-options" flag
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we get a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @opts, $_     # then push item to @opts
      or  push @args, $_;    # else push item to @args.
   }

   # Process options:
   for ( @opts ) {
      /^-$s*h/ || /^--help$/      and help and exit 777 ;
      /^-$s*d/ || /^--debug$/     and $Db      =  1     ; # Default is 0.
      /^-$s*q/ || /^--quiet$/     and $Verbose =  0     ; # Default is 0.
      /^-$s*v/ || /^--verbose$/   and $Verbose =  1     ;
      /^-$s*l/ || /^--local$/     and $Recurse =  0     ; # Default is 0.
      /^-$s*r/ || /^--recurse$/   and $Recurse =  1     ;
      /^-$s*e/ || /^--empty$/     and $Empty   =  1     ;
      if ( $_ =~ m/^--gb=(\d+\.?\d*)$/ ) {
         $GB = $1;
         say "set \$GB = $1" if $Db;
      }
      if ( $_ =~ m/^--files=(\d+)$/ ) {
         $Files = $1;
         say "set \$Files = $1" if $Db;
      }
   }
   if ( $Db ) {
      say STDERR '';
      say STDERR "\$opts = (", join(', ', map {"\"$_\""} @opts), ')';
      say STDERR "\$args = (", join(', ', map {"\"$_\""} @args), ')';
   }

   # Process arguments:
   my $NA = scalar(@args);     # Get number of arguments.
   if ( $NA >= 1 ) {           # If number of arguments >= 1,
      $RegExp = qr/$args[0]/;  # set $RegExp to $args[0].
   }
   if ( $NA >= 2 && !$Db ) {   # If number of arguments >= 2 and we're not debugging,
      error($NA);              # print error message,
      help;                    # and print help message,
      exit 666;                # and exit, returning The Number Of The Beast.
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Get CWD:
   my $curdir = cwd;

   # Get ref to array of refs to hashes of info on all regular files in current working directory:
   my $curdirfiles = GetFiles($curdir, 'F', $RegExp);
   # Note: these files might also be b,c,p,S,t, but those can take-up space also, and we're interested in
   # tallying ALL storage space used, including storage space used by weird files.

   # Tally bytes of data stored in all regular files in current directory:
   my $bytes = 0;
   foreach my $file ( @$curdirfiles ) {
      $bytes += $file->{Size};
   }
   my $gigabytes = $bytes/1000000000.0;

   # If in "show empties only" mode,
   # then only print directories which contain zero regular files:
   if ($Empty)
   {
      if ( 0 == $RH::Dir::totfcount ) {
         ++$direcount;
         say STDOUT "Empty: $curdir";
      }
      else {
         ; # Do nothing.
      }
   }

   # Otherwise, we're NOT in "show empties only" mode, so display info for this directory
   # if it contains at-least $Files files or at-least $GB gigabytes of data:
   else {
      if ($RH::Dir::totfcount >= $Files && $gigabytes >= $GB) {
         ++$direcount;
         $filecount += $RH::Dir::totfcount;
         $gigacount += $gigabytes;
         printf STDOUT "%7d Files %9.3fGB: %s\n", $RH::Dir::totfcount, $gigabytes, $curdir;
      }
      else {
         ; # Do nothing.
      }
   }
   return 1;
} # end sub curdire

sub tree_stats {
   say STDERR '';
   say STDERR "Found $direcount directories matching given files limit and size limit.";
   say STDERR "Those directories contain $filecount regular files matching given regexp,";
   say STDERR "and take-up $gigacount GB of storage space.";
   return 1;
} # end sub tree_stats

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
   -q or --quiet      Don't print entry/exit/stats messages.             (DEFAULT)
   -v or --verbose    Do    print entry/exit/stats messages.
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
   census.pl will print info on any directories which contain either
   1.3GB-or-more of content OR 500+ files.

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
   Description of arguments:

   In addition to options, this program can take optional argument.

   Arg1 (OPTIONAL), if present, must be a Perl-Compliant Regular Expression
   specifying which file names to process. To specify multiple patterns, use the
   | alternation operator. To apply pattern modifier letters, use an Extended
   RegExp Sequence. For example, if you want to process items with names
   containing "cat", "dog", or "horse", title-cased or not, you could use this
   regexp: '(?i:c)at|(?i:d)og|(?i:h)orse'
   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   A number of arguments other than 0 or 1 will cause this program to print an
   error message and this help message and exit.

   Happy directory storage-space-usage reporting!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
