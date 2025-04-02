#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# dir-stats.pl
# Prints counts of each type of file found in current directory (and all subdirectories if a -r or --recurse
# option is used).
#
# Edit history:
# Sat Jan 02, 2021: Wrote it.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Wed Sep 06, 2023: Reduced width from 120 to 110. Upgraded from "v5.32" to "v5.36". Updated which file stats
#                   to print (variables in RH::Dir have changed, causing errors in this program). All messages
#                   and stats are to STDOUT; STDERR in this program is for errors and debugging only. There
#                   are no verbosity controls, as the whole purpose of this program is to print statistics.
# Wed Sep 06, 2023: Predicate now overrides target and forces it to 'A' to avoid conflicts with predicate.
# Wed Aug 14, 2024: Removed unnecessary "use" statements.
# Tue Mar 04, 2025: Got rid of all prototypes and empty sigs.
##############################################################################################################

use v5.36;
use utf8;
use Cwd;
use Time::HiRes 'time';
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv       ;
sub curdire    ;
sub dire_stats ;
sub tree_stats ;
sub error      ;
sub help       ;

# ======= LEXICAL VARIABLES: =================================================================================

# Settings:
#  Setting:     Default:      Meaning of setting:       Range:    Meaning of default:
my $Db        = 0         ; # Print diagnostics?        bool      Don't print diagnostics.
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $Target    = 'A'       ; # Target                    F|D|B|A   Process all file types.
my $RegExp    = qr/^.+$/  ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # File-type boolean.        bool      Process all file-type combos.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire().
my $filecount = 0 ; # Count of files found which match $Target and $RegExp.
my $predcount = 0 ; # Count of files found which also match file-type predicate.
my $livecount = 0 ; # Count of files verified to exist.
my $deadcount = 0 ; # Count of fiels verified to NOT exist.

# Accumulations of counters from RH::Dir::GetFiles():
my $totfcount = 0 ; # Count of all directory entries matching regexp & target.
my $noexcount = 0 ; # Count of all nonexistent files encountered.
my $ottycount = 0 ; # Count of all tty files.
my $cspccount = 0 ; # Count of all character special files.
my $bspccount = 0 ; # Count of all block special files.
my $sockcount = 0 ; # Count of all sockets.
my $pipecount = 0 ; # Count of all pipes.
my $brkncount = 0 ; # Count of all symbolic links to nowhere
my $slkdcount = 0 ; # Count of all symbolic links to directories.
my $linkcount = 0 ; # Count of all symbolic links to regular files.
my $weircount = 0 ; # Count of all symbolic links to weirdness (things other than files or dirs).
my $sdircount = 0 ; # Count of all directories.
my $hlnkcount = 0 ; # Count of all regular files with multiple hard links.
my $regfcount = 0 ; # Count of all regular files.
my $unkncount = 0 ; # Count of all unknown files.

# Array of paths verified to NOT exist (should always be empty):
my @deadpaths = ();

# ======= MAIN BODY OF PROGRAM: ==============================================================================
{
   # Set time and program variables:
   my $t0 = time;
   my $pname = substr $0, 1 + rindex $0, '/';

   # Process @ARGV:
   argv;

   # Print entry message:
   say    '';
   say    "Now entering program \"$pname\"." ;
   say    "\$Db        = $Db"        ;
   say    "\$Recurse   = $Recurse"   ;
   say    "\$Target    = $Target"    ;
   say    "\$RegExp    = $RegExp"    ;
   say    "\$Predicate = $Predicate" ;

   # Process current directory (and all subdirectories if recursing):
   $Recurse and RecurseDirs {curdire} or curdire;

   # Print stats for this directory tree:
   tree_stats;

   # Print exit message, including elapsed time:
   say    '';
   say    "Now exiting program \"$pname\".";
   printf "Execution time was %.3f seconds.", time - $t0;

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

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
      /^-$s*h/ || /^--help$/    and help and exit 777 ;
      /^-$s*e/ || /^--debug$/   and $Db      =  1     ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0     ; # DEFAULT
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1     ;
      /^-$s*f/ || /^--files$/   and $Target  = 'F'    ;
      /^-$s*d/ || /^--dirs$/    and $Target  = 'D'    ;
      /^-$s*b/ || /^--both$/    and $Target  = 'B'    ;
      /^-$s*a/ || /^--all$/     and $Target  = 'A'    ; # DEFAULT
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
   if ( $NA >= 2 ) {           # If number of arguments >= 2,
      $Predicate = $args[1];   # set $Predicate to $args[1]
      $Target = 'A';           # and set $Target to 'A' to avoid conflicts with $Predicate.
   }
   if ( $NA >= 3 && !$Db ) {   # If number of arguments >= 3 and we're not debugging,
      error($NA);              # print error message,
      help;                    # and print help message,
      exit 666;                # and exit, returning The Number Of The Beast.
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Increment directory counter.
   ++$direcount;

   # Get and announce current working directory:
   my $curdir = cwd_utf8;
   say '';
   say "Directory #$direcount: $curdir";

   if ( $Db ) {
      say STDERR '';
      say STDERR "Debug message. In curdire; just got cwd.";
      say STDERR "\$Target = \"$Target\". \$RegExp = \"$RegExp\".";
   }

   # Get list of all entries in current directory matching $Target and $RegExp:
   my $curdirfiles = GetFiles($curdir, $Target, $RegExp);

   # Iterate through these files. Increment $filecount for every file. Increment $livecount for files
   # verified to exist. For files verifed to NOT exist, increment $deadcount and push to @deadpaths:
   foreach my $file ( @{$curdirfiles} ) {
      ++$filecount;
      local $_ = e $file->{Path};
      if (eval($Predicate)) {
         ++$predcount;
         if ( -e e $file->{Path} ) {
            ++$livecount;
         }
         else {
            ++$deadcount;
            push @deadpaths, $file->{Path};
         }
      }
   }

   # Print stats for this directory:
   dire_stats;

   # Append all counters from "RH::Dir" to "dir-stats.pl" accumulators for use by tree_stats:
   $totfcount += $RH::Dir::totfcount; # all directory entries found
   $noexcount += $RH::Dir::noexcount; # nonexistent files
   $ottycount += $RH::Dir::ottycount; # tty files
   $cspccount += $RH::Dir::cspccount; # character special files
   $bspccount += $RH::Dir::bspccount; # block special files
   $sockcount += $RH::Dir::sockcount; # sockets
   $pipecount += $RH::Dir::pipecount; # pipes
   $brkncount += $RH::Dir::slkdcount; # symbolic links to nowhere
   $slkdcount += $RH::Dir::slkdcount; # symbolic links to directories
   $linkcount += $RH::Dir::linkcount; # symbolic links to regular files
   $weircount += $RH::Dir::weircount; # symbolic links to weirdness
   $sdircount += $RH::Dir::sdircount; # directories
   $hlnkcount += $RH::Dir::hlnkcount; # regular files with multiple hard links
   $regfcount += $RH::Dir::regfcount; # regular files
   $unkncount += $RH::Dir::unkncount; # unknown files

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

sub dire_stats {
   say '';
   say "Entries encountered in this directory included:";
   printf "%7u total files.\n",                           $RH::Dir::totfcount;
   printf "%7u nonexistent files.\n",                     $RH::Dir::noexcount;
   printf "%7u tty files\n",                              $RH::Dir::ottycount;
   printf "%7u character special files\n",                $RH::Dir::cspccount;
   printf "%7u block special files\n",                    $RH::Dir::bspccount;
   printf "%7u sockets\n",                                $RH::Dir::sockcount;
   printf "%7u pipes\n",                                  $RH::Dir::pipecount;
   printf "%7u symbolic links to nowhere\n",              $RH::Dir::brkncount;
   printf "%7u symbolic links to directories\n",          $RH::Dir::slkdcount;
   printf "%7u symbolic links to non-directories\n",      $RH::Dir::linkcount;
   printf "%7u symbolic links to weirdness\n",            $RH::Dir::weircount;
   printf "%7u directories\n",                            $RH::Dir::sdircount;
   printf "%7u regular files with multiple hard links\n", $RH::Dir::hlnkcount;
   printf "%7u regular files\n",                          $RH::Dir::regfcount;
   printf "%7u files of unknown type\n",                  $RH::Dir::unkncount;
   return 1;
} # end sub dire_stats

sub tree_stats {
   say '';
   say "Statistics for this directory tree:";
   say "Navigated $direcount directories.";
   say "Examined $filecount files matching target \"$Target\" and regexp \"$RegExp\".";
   say "Found $predcount files also matching predicate \"$Predicate\".";
   say "Found $livecount files verified to exist.";
   say "Found $deadcount files verified to NOT exist.";

   if ($direcount > 1) {
      say    '';
      say    'Directory entries encountered in this tree included:';
      printf "%7u total files\n",                            $totfcount;
      printf "%7u nonexistent files\n",                      $noexcount;
      printf "%7u tty files\n",                              $ottycount;
      printf "%7u character special files\n",                $cspccount;
      printf "%7u block special files\n",                    $bspccount;
      printf "%7u sockets\n",                                $sockcount;
      printf "%7u pipes\n",                                  $pipecount;
      printf "%7u symbolic links to nowhere\n",              $brkncount;
      printf "%7u symbolic links to directories\n",          $slkdcount;
      printf "%7u symbolic links to non-directories\n",      $linkcount;
      printf "%7u symbolic links to weirdness\n",            $weircount;
      printf "%7u directories\n",                            $sdircount;
      printf "%7u regular files with multiple hard links\n", $hlnkcount;
      printf "%7u regular files\n",                          $regfcount;
      printf "%7u files of unknown type\n",                  $unkncount;
   }

   say '';
   if ( $deadcount > 0 ) {
      say "List of paths verified to NOT exist:";
      say for @deadpaths;
   }
   else {
      say "No non-existent paths found.";
   }

   return 1;
} # end sub tree_stats

sub error ($NA) {
   print ((<<'   END_OF_ERROR') =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes 0, 1, or 2 arguments.
   Help follows:
   END_OF_ERROR
   return 1;
} # end sub error

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "dir-stats.pl", Robbie Hatley's nifty directory statistics
   printing program. This program prints stats on all of the objects in the
   current directory (and all subdirectories if a -r or --recurse option
   is used).

   -------------------------------------------------------------------------------
   Command lines:

   dir-stats.pl -h | --help                       (to print this help and exit)
   dir-stats.pl [options] [Arg1] [Arg2] [Arg3]    (to print directory statistics)

   -------------------------------------------------------------------------------
   Description of options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics.
   -l or --local      DON'T recurse subdirectories.     (DEFAULT)
   -r or --recurse    DO    recurse subdirectories.
   -f or --files      Target Files.
   -d or --dirs       Target Directories.
   -b or --both       Target Both.
   -a or --all        Target All.                       (DEFAULT)
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively print directory statistics.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: heabdfrl.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of arguments:

   This program can take 0, 1, or 2 arguments.

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
   program intact). If this argument is used, it overrides "--files", "--dirs",
   or "--both", and sets target to "--all" in order to avoid conflicts with
   the predicate.

   Here are some examples of valid and invalid predicate arguments:
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

   A number of arguments greater than 2 will cause this program to print an error
   message and abort.

   Happy directory statistics printing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
