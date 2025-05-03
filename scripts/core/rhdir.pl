#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# rhdir.pl
# Prints information about every file in current working directory (and all subdirectories if a -r or
# --recurse option is used). NOTE: This program works in Cygwin as well as in Linux.
# Edit history:
# Sat Dec 06, 2014: Wrote it. (Date is approximate.)
# Fri Jul 17, 2015: Upgraded for utf8.
# Mon Apr 04, 2016: Simplified.
# Sat Apr 16, 2016: Now using -CSDA.
# Sun Sep 23, 2018: "errocount" => "noexcount", and added inodes.
# Sun Sep 30, 2018: Now also discerns hard links.
# Tue Feb 01, 2021: Refactored to use the new GetFiles($dir, $target, $regexp).
# Tue Mar 09, 2021: Changed help() to reflect fact that we're now using PCREs instead of csh wildcards.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Sat Jul 30, 2022: Now sorts files within each type, so one doesn't get a random jumble of "regular files"
#                   as before. Removed type "M", because in Linux, ALL directories have multiple hard links
#                   pointing to them because of "." and "..". All directories are now type "D" instead of "M".
#                   Corrected omission in help(), which failed to mention the number-of-links column.
#                   Removed mention of "directories with multiple hard links" from dir_stats and tree_stats.
# Sun Jul 30, 2023: Upgraded from "use v5.32;" to "use v5.36;". Got rid of "common::sense" (antiquated).
#                   Got rid of "prototypes". Now using "signature" for error() and dir_stats().
#                   Got rid of all usage of given/when. Reduced width from 120 to 110 with github in mind.
#                   Now counting broken symbolic links and symbolic links to "other than file or directory".
#                   Sub error() is now single-purpose (on error, help and exit are called from argv instead).
#                   Multiple single-letter options can now be piled-up after a single hyphen.
# Mon Jul 31, 2023: Cleaned up formatting and comments. Fine-tuned definitions of "option" and "argument".
#                   Fixed bug in which $, was being set instead of $" . Improved help.
#                   Got rid of "--target=xxxx" options in favor of just "--xxxx".
# Mon Aug 21, 2023: An "option" is now "one or two hyphens followed by 1-or-more word characters".
#                   Reformatted debug printing of opts and args to ("word1", "word2", "word3") style.
#                   Inserted text into help explaining the use of "--" as "end of options" marker.
# Mon Aug 28, 2023: Updated argv. Got rid of "/o" in every instance of qr(). Changed all $db to $Debug.
#                   Entry and exit blurbs now controlled only by $Verbose. Clarified argv. Now using "||"
#                   between separate short and long /regexps/ for processing options. Now using map and join
#                   instead of separate print statements for printing options and arguments. Fixed "--debut"
#                   bug in argv (should have been --debug).
# Thu Oct 03, 2024: Got rid of Sys::Binmode.
# Wed Mar 19, 2025: Changed shebang to "-C63". Cleaned-up quoting of CPAN module functions. Typing more than 2
#                   arguments now just triggers a warning, rather than aborting the program. Help, recurse,
#                   and stats are now all on one line, controlled by "and" and "or" for coordination.
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e", and now using "cwd" instead of "d getcwd".
# Fri May 02, 2025: Reverted "utf8::all" -> "utf8" and "Cwd::utf8" -> "Cwd", due to Cygwin issues.
#                   Reverted shebang to "#!/usr/bin/env -S perl -C63".
##############################################################################################################

use v5.36;
use utf8;
use Cwd;
use Time::HiRes 'time';
use Data::Dumper;
use RH::Dir;

# ======= VARIABLES: =========================================================================================

# System Variables:

$" = ', ' ; # Quoted-array element separator = ", ".

# Global Variables:

our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.
our    $cmpl_beg;                              # Declare compilation begin time.
BEGIN {$cmpl_beg = time}                       # Set     compilation begin time.
our    $cmpl_end;                              # Declare compilation end   time.
INIT  {$cmpl_end = time}                       # Set     compilation end   time.

# Local variables:

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 0         ; # Be verbose?               0,1,2     Be quiet.
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $Target    = 'A'       ; # Target                    F|D|B|A   Target all directory entries.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    List files of all names.
my $Predicate = '1'       ; # Boolean predicate.        eval      List files of all types.
my $OriDir    = d cwd     ; # Original directory.       cwd       Directory on program entry.
my $Inodes    = 0         ; # Print inodes?             bool      Don't print inodes.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed.
my $filecount = 0 ; # Count of files matching given target, regexp, and predicate.

# Accumulations of counters from RH::Dir :
my $totfcount = 0 ; # Count of all directory entries encountered.
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
my $hlnkcount = 0 ; # Count of all regular files with  > 1 hard links.
my $regfcount = 0 ; # Count of all regular files with == 1 hard links.
my $orphcount = 0 ; # Count of all regular files with == 0 hard links.
my $zombcount = 0 ; # Count of all regular files with  < 0 hard links.
my $unkncount = 0 ; # Count of all unknown files.

# Hashes:
my %Targets;
$Targets{F} = "Files Only";
$Targets{D} = "Directories Only";
$Targets{B} = "Both Files And Directories";
$Targets{A} = "All Directory Entries";

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv       ; # Process @ARGV and set settings.
sub curdire    ; # Process current directory.
sub dir_stats  ; # Print directory stats.
sub tree_stats ; # Print tree stats.
sub help       ; # Print help.

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
      say STDERR "Recurse   = $Recurse";
      say STDERR "Target    = $Target";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR "OriDir    = $OriDir";
      say STDERR "Inodes    = $Inodes";
      say STDERR '';
   }

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   if ($Help) {
      help;
   }
   else {
      $Recurse and RecurseDirs {curdire} or curdire;
      tree_stats;
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

# ======= SUBROUTINE DEFINITIONS =============================================================================

sub argv {
   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV:
      !$end                  # If we haven't yet reached end-of-options,
      && /^--$/              # and we see an "--" option,
      and $end = 1           # set the "end-of-options" flag
      and push @Opts, '--'   # and push "--" to @Opts
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we get a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @Opts, $_     # then push item to @Opts
      and next;              # and skip to next element of @ARGV.
      push @Args, $_;        # Otherwise, push item to @Args.
   }

   # Process options:
   for ( @Opts ) {
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
      /^-$s*e/ || /^--debug$/   and $Debug   =  1  ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0  ; # Default is "be quiet".
      /^-$s*t/ || /^--terse$/   and $Verbose =  1  ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2  ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0  ; # Default is "don't recurse".
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1  ;
      /^-$s*f/ || /^--files$/   and $Target  = 'F' ;
      /^-$s*d/ || /^--dirs$/    and $Target  = 'D' ;
      /^-$s*b/ || /^--both$/    and $Target  = 'B' ;
      /^-$s*a/ || /^--all$/     and $Target  = 'A' ; # Default is "process all types".
      /^-$s*i/ || /^--inodes$/  and $Inodes  =  1  ; # Default is "don't print inodes".
   }

   # Process arguments:

   # Get number of arguments:
   my $NA = scalar(@Args);

   # First argument, if present, is a file-selection regexp:
   if ( $NA >= 1 ) {             # If number of arguments is 1-or-more,
      $RegExp = qr/$Args[0]/o;   # set $RegExp to $Args[0].
   }

   # Second argument, if present, is a file-selection predicate:
   if ( $NA >= 2 ) {             # If number of arguments is 2-or-more,
      $Predicate = $Args[1];     # set $Predicate to $Args[1].
   }

   # If user typed more than 2 arguments, warn that they'll be ignored:
   if ( $NA >= 3 ) {
      say STDERR 'Warning: Arguments after first 2 will be ignored.';
      say STDERR 'Use "-h" or "--help" to get help.';
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Increment directory counter:
   ++$direcount;

   # Get current working directory:
   my $curdir = d cwd;

   if ($Debug) {say STDERR "In \"rhdir.pl\", in \"curdire()\"; \$curdir = \"$curdir\".";}

   # Get list of files in current directory matching target, regexp, and predicate:
   my $curdirfiles = GetFiles($curdir, $Target, $RegExp, $Predicate);

   # Record number of files obtained:
   my $nf = scalar(@{$curdirfiles});

   # If being VERY verbose, also accumulate all counters from RH::Dir:: to main:
   if ( $Verbose >= 2 ) {
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
      $hlnkcount += $RH::Dir::hlnkcount; # regular files with  > 1 hard links
      $regfcount += $RH::Dir::regfcount; # regular files with == 1 hard links
      $orphcount += $RH::Dir::orphcount; # regular files with == 0 hard links
      $zombcount += $RH::Dir::zombcount; # regular files with  < 0 hard links
      $unkncount += $RH::Dir::unkncount; # unknown files
   }

   # Make a hash of refs to lists of refs to file-record hashes, keyed by type:
   my %TypeLists;

   # Autovivify type arrays in %TypeLists, and push refs to file-record hashes into those arrays:
   foreach my $file (@{$curdirfiles}) {
      push @{$TypeLists{$file->{Type}}}, $file;
   }

   # Append local files counter to global files counter:
   $filecount += $nf;

   # Announce current working drectory (because file listings don't mention directory):
   say "\nDirectory # $direcount (with $nf files): $curdir\n";

   # If $nf is 0, announced that the directory is empty then return 1, because %TypeLists is empty,
   # so we have no files to print and don't water to clutter the screen with bizarre floating headers:
   if ( 0 == $nf ) {
      say "[DIRECTORY IS EMPTY]";
      return 1;
   }

   # If debugging, use Data::Dumper to print contents of %TypeLists:
   if ($Debug) {print Dumper \%TypeLists}

   # Make a list of types:
   my @Types = split //,'DRLWXBCPSTHFUN';

   # Directory Listing (if in inodes mode):
   if ($Inodes)
   {
      say 'T: Date:       Time:        Size:      Inode:      L:   Bsize:  Blocks:  Name:';
      foreach my $type (@Types)
      {
         foreach my $file (sort {fc($a->{Name}) cmp fc($b->{Name})} @{$TypeLists{$type}})
         {
            printf "%-1s  %-10s  %-11s  %-8.2E  %10d  %3u  %7u  %7u  %-s\n",
                   $file->{Type},  $file->{Date},   $file->{Time},
                   $file->{Size},  $file->{Inode},  $file->{Nlink},
                   $file->{Bsize}, $file->{Blocks}, $file->{Name};
         }
      }
   }

   # Directory Listing (if NOT in inodes mode):
   else
   {
      say 'T: Date:       Time:        Size:     L:   Name:';
      foreach my $type (@Types)
      {
         foreach my $file (sort {fc($a->{Name}) cmp fc($b->{Name})} @{$TypeLists{$type}})
         {
            printf "%-1s  %-10s  %-11s  %-8.2E  %3u  %-s\n",
                   $file->{Type}, $file->{Date},  $file->{Time},
                   $file->{Size}, $file->{Nlink}, $file->{Name};
         }
      }
   }

   # Print stats for this directory:
   dir_stats($curdir, $nf);

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

sub dir_stats ($curdir, $nf) {
   if ( $Verbose >= 1 ) {
      say    STDERR '';
      say    STDERR "Statistics for running \"$pname\" on \"$OriDir\" directory tree:";
      say    STDERR "Navigated $direcount directories. Found $filecount files matching";
      say    STDERR "target \"$Target\", regexp \"$RegExp\", and predicate \"$Predicate\".";
   }

   if ( $Verbose >= 2) {
      say    STDERR '';
      say    STDERR 'Directory entries encountered in this tree included:';
      printf STDERR "%7u total files\n",                            $totfcount;
      printf STDERR "%7u nonexistent files\n",                      $noexcount;
      printf STDERR "%7u tty files\n",                              $ottycount;
      printf STDERR "%7u character special files\n",                $cspccount;
      printf STDERR "%7u block special files\n",                    $bspccount;
      printf STDERR "%7u sockets\n",                                $sockcount;
      printf STDERR "%7u pipes\n",                                  $pipecount;
      printf STDERR "%7u symbolic links to nowhere\n",              $brkncount;
      printf STDERR "%7u symbolic links to directories\n",          $slkdcount;
      printf STDERR "%7u symbolic links to non-directories\n",      $linkcount;
      printf STDERR "%7u symbolic links to weirdness\n",            $weircount;
      printf STDERR "%7u directories\n",                            $sdircount;
      printf STDERR "%7u regular files with  > 1 hard links\n",     $hlnkcount;
      printf STDERR "%7u regular files with == 1 hard links\n",     $regfcount;
      printf STDERR "%7u regular files with == 0 hard links\n",     $orphcount;
      printf STDERR "%7u regular files with  < 0 hard links\n",     $zombcount;
      printf STDERR "%7u files of unknown type\n",                  $unkncount;
   }
   return 1;
} # end sub dir_stats ($curdir)

sub tree_stats {
   if ( $Verbose >= 1 ) {
      say STDERR "\nStatistics for running \"$pname\" on tree descending from \"$OriDir\":";
      say STDERR "Navigated $direcount directories.";
      say STDERR "Found $filecount files matching given target, regexp, and predicate.";
   }
   if ( $Verbose >= 2 ) {
      say    STDERR "\nDirectory entries encountered in this tree included:";
      printf STDERR "%7u total files\n",                            $totfcount;
      printf STDERR "%7u directories\n",                            $sdircount;
      printf STDERR "%7u symbolic links to directories\n",          $slkdcount;
      printf STDERR "%7u symbolic links to files\n",                $linkcount;
      printf STDERR "%7u symbolic links to weirdness\n",            $weircount;
      printf STDERR "%7u symbolic links to nowhere\n",              $brkncount;
      printf STDERR "%7u block special files\n",                    $bspccount;
      printf STDERR "%7u character special files\n",                $cspccount;
      printf STDERR "%7u pipes\n",                                  $pipecount;
      printf STDERR "%7u sockets\n",                                $sockcount;
      printf STDERR "%7u tty files\n",                              $ottycount;
      printf STDERR "%7u regular files with multiple hard links\n", $hlnkcount;
      printf STDERR "%7u regular files\n",                          $regfcount;
      printf STDERR "%7u files of unknown type\n",                  $unkncount;
      printf STDERR "%7u non-existent directory entries\n",         $noexcount;
   }
   return 1;
} # end sub tree_stats

sub help
{
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to RHDir, Robbie Hatley's Nifty directory listing utility.
   RHDir will list all files and/or folders and/or other objects in
   the current directory (and all subdirectories if a -r or --recurse
   option is used). Each listing line will give the following pieces
   of information about a file:
   1. Type of file (single-letter code; see chart below).
   2. Last-modified Date of file.
   3. Last-modified Time of file.
   4. Size of file in format #.##E+##
   5. Number of hard links to file.
   6. Name of file.
   If a "-i" or "--inodes" option is used, the inode number,
   recommended block size, and number of blocks are also printed.
   NOTE: This program works in Cygwin as well as in Linux.

   -------------------------------------------------------------------------------
   Type Letters:

   The meanings of the Type letters, in alphabetical order, are as follows:
   B - block special file
   C - character special file
   D - Directory
   F - regular File
   H - regular file with multiple Hard links
   L - symbolic link to regular fiLe
   N - Nonexistent
   S - Socket
   P - Pipe
   R - symbolic link to diRectory
   T - opens to a Tty
   U - Unknown
   W - symbolic link to something Weird (not a regular file or directory)
   X - Broken symbolic link

   NOTE: In listings, these will appear in order DRLWXBCPSTHFUN, so that we have
   directories first (D), then links (RLWX), then non-link special files (BCPST),
   files with multiple hard links (H), regular files (F), unknown files (U), and,
   lastly, nonexistent files (N).

   -------------------------------------------------------------------------------
   Verbosity levels:

   This program has 3 verbosity levels:
   Level 0 - "Quiet" (DEFAULT)
   Level 1 - "Terse"
   Level 2 - "Verbose"

   At verbosity Level 0, this program will print matching file paths only.
   At verbosity Level 1, basic statistics will also be printed.
   At verbosity Level 2, counts of all file types encountered are also printed.

   -------------------------------------------------------------------------------
   Command lines:

   rhdir.pl [-h | --help]            (to print this help and exit)
   rhdir.pl [options] [Arguments]    (to list directory entries  )

   -------------------------------------------------------------------------------
   Description of options:

   Option:             Meaning:
   -h or --help        Print help and exit.
   -e or --debug       Print diagnostics using Data::Dumper.
   -q or --quiet       Be  non-verbose (list   no     stats).            (DEFAULT)
   -t or --terse       Be semi-verbose (list limited  stats).
   -v or --verbose     Be VERY-verbose (list   all    stats).
   -l or --local       Don't recurse subdirectories.                     (DEFAULT)
   -r or --recurse     Do    recurse subdirectories.
   -f or --files       List files only.
   -d or --dirs        List directories only.
   -b or --both        List both files and directories.
   -a or --all         List all directory entries.                       (DEFAULT)
   -i or --inodes      Print inode numbers, block sizes, & #s of blocks.
         --            End of options (all further CL items are arguments).

   Defaults (what will be printed if no options or arguments are used):
    - Give file listings for files of all types (dir, reg, link, pipe, etc).
    - Print basic stats such as how many directories and files were processed.
    - Don't print counts of how many files of each type were encountered.
    - List files in current directory only (don't recurse).
    - Don't print inode numbers, recommended block sizes, or number of blocks.

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively process items.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: heiabdfrlvtq.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of arguments:

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

   Arg2 (OPTIONAL), if present, must be a boolean expression using Perl
   file-test operators. The expression must be enclosed in parentheses (else
   this program will confuse your file-test operators for options), and then
   enclosed in single quotes (else the shell won't pass your expression to this
   program intact). Here are some examples of valid and invalid second arguments:

   '(-d && -l)'  # VALID:   Finds symbolic links to directories
   '(-l && !-d)' # VALID:   Finds symbolic links to non-directories
   '(-b)'        # VALID:   Finds block special files
   '(-c)'        # VALID:   Finds character special files
   '(-S || -p)'  # VALID:   Finds sockets and pipes.  (S must be CAPITAL S   )
    '-d && -l'   # INVALID: missing parentheses       (confuses program      )
    (-d && -l)   # INVALID: missing quotes            (confuses shell        )
     -d && -l    # INVALID: missing parens AND quotes (confuses prgrm & shell)

   (Exception: Technically, you can use an integer as a boolean, and it doesn't
   need quotes or parentheses; but if you use an integer, any non-zero integer
   will process all paths and 0 will process no paths, so this isn't very useful.)

   Arguments and options may be freely mixed, but the arguments must appear in
   the order Arg1, Arg2 (RegExp first, then File-Type Predicate); if you get them
   backwards, they won't do what you want, as most predicates aren't valid regexps
   and vice-versa.

   A number of arguments other than 0, 1, or 2 will cause this program to print
   error and help messages and abort.

   Happy directory listing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
