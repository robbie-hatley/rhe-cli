#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# rhdir.pl
# Prints information about every file in current working directory (and all subdirectories if a -r or
# --recurse option is used).
#
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
# Mon Aug 28, 2023: Updated argv. Got rid of "/o" in every instance of qr(). Changed all $db to $Db.
#                   Entry and exit blurbs now controlled only by $Verbose. Clarified argv. Now using "||"
#                   between separate short and long /regexps/ for processing options. Now using map and join
#                   instead of separate print statements for printing options and arguments. Fixed "--debut"
#                   bug in argv (should have been --debug).
# Thu Oct 03, 2024: Got rid of Sys::Binmode.
##############################################################################################################

use v5.36;
use utf8;

use Cwd           qw( cwd getcwd   );
use Time::HiRes   qw( time         );
use Data::Dumper  qw( :DEFAULT     );

use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv       ;
sub curdire    ;
sub dir_stats  ;
sub tree_stats ;
sub error      ;
sub help       ;

# ======= VARIABLES: =========================================================================================

# Settings:     Default Val:   Meaning of Setting:        Range:    Meaning of Default:
my $Db        = 0          ; # Debug?                     0,1       Don't debug.
my $Verbose   = 1          ; # Be verbose?                0,1,2     Be somewhat verbose.
my $Recurse   = 0          ; # Recurse subdirectories?    bool      Don't recurse.
my $Target    = 'A'        ; # Target                     F|D|B|A   List files of all types.
my $RegExp    = qr/.+/     ; # Regular Expression.        regexp    List files of all names.
my $Predicate = 1          ; # file-type boolean          bool      All file types.
my $Inodes    = 0          ; # Print inodes?              bool      Don't print inodes.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed.
my $filecount = 0 ; # Count of files matching $Target and $RegExp.
my $predcount = 0 ; # Count of files also matching $Predicate.

# Accumulations of counters from RH::Dir :
my $totfcount = 0 ; # Count of all files.
my $sdircount = 0 ; # Count of all directories.
my $slkdcount = 0 ; # Count of all symbolic links to directories.
my $linkcount = 0 ; # Count of all symbolic links to files.
my $weircount = 0 ; # Count of all symbolic links to weirdness.
my $brkncount = 0 ; # Count of all symbolic links to nowhere.
my $bspccount = 0 ; # Count of all block special files.
my $cspccount = 0 ; # Count of all character special files.
my $pipecount = 0 ; # Count of all pipes.
my $sockcount = 0 ; # Count of all sockets.
my $ottycount = 0 ; # Count of all tty files.
my $hlnkcount = 0 ; # Count of all regular files with multiple hard links.
my $regfcount = 0 ; # Count of all regular files.
my $unkncount = 0 ; # Count of all unknown files.
my $noexcount = 0 ; # Count of all nonexistent files encountered.

# Hashes:
my %Targets;
$Targets{F} = "Files Only";
$Targets{D} = "Directories Only";
$Targets{B} = "Both Files And Directories";
$Targets{A} = "All Directory Entries";

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Set time and program variables:
   my $t0 = time;
   my $pname = get_name_from_path($0);

   # Process @ARGV:
   argv;

   # Print entry message:
   say    STDERR "Now entering program \"$pname\".";
   say    STDERR "\$Db        = $Db"        ;
   say    STDERR "\$Verbose   = $Verbose"   ;
   say    STDERR "\$Recurse   = $Recurse"   ;
   say    STDERR "\$Target    = $Target"    ;
   say    STDERR "\$Regexp    = $RegExp"    ;
   say    STDERR "\$Predicate = $Predicate" ;
   say    STDERR "\$Inodes    = $Inodes"    ;

   # Process current directory (and all subdirectories if recursing):
   $Recurse and RecurseDirs {curdire} or curdire;

   # Print stats for this directory tree:
   tree_stats;

   # Print exit message:
   say    STDERR '';
   say    STDERR "Now exiting program \"$pname\".";
   printf STDERR "Execution time was %.3f seconds.", time - $t0;
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS =============================================================================

sub argv {
   # Get options and arguments:
   my @opts = ()            ; # options
   my @args = ()            ; # arguments
   my $end = 0              ; # end-of-options flag
   my $s = '[a-zA-Z0-9]'    ; # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]' ; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {
      /^--$/                  # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1            # so if we see that, then set the "end-of-options" flag
      and next;               # and skip to next element of @ARGV.
      !$end                   # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/      # and if we get a valid short option
      ||   /^--(?!-)$d+$/ )   # or a valid long option,
      and push @opts, $_      # then push item to @opts
      or  push @args, $_;     # else push item to @args.
   }

   # Process options:
   for ( @opts ) {
      /^-$s*h/ || /^--help$/    and help and exit 777 ;
      /^-$s*e/ || /^--debug$/   and $Db      =  1     ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0     ;
      /^-$s*t/ || /^--terse$/   and $Verbose =  1     ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2     ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0     ;
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1     ;
      /^-$s*f/ || /^--files$/   and $Target  = 'F'    ;
      /^-$s*d/ || /^--dirs$/    and $Target  = 'D'    ;
      /^-$s*b/ || /^--both$/    and $Target  = 'B'    ;
      /^-$s*a/ || /^--all$/     and $Target  = 'A'    ;
      /^-$s*i/ || /^--inodes$/  and $Inodes  =  1     ;
   }
   if ( $Db ) {
      say STDERR '';
      say STDERR '$opts = (', join(', ', map {"\"$_\""} @opts), ')';
      say STDERR '$args = (', join(', ', map {"\"$_\""} @args), ')';
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
   ++$direcount;
   my $curdir = d getcwd;
   say STDOUT "\nDir # $direcount: \"$curdir\"";

   # Get list of files in current directory matching $Target and $RegExp:
   my $curdirfiles = GetFiles($curdir, $Target, $RegExp);

   if ($Db)
   {
      say STDERR '';
      say STDERR 'Db msg from curdire, near top, just ran GetFiles().';
      say STDERR "cwd = \"$curdir\".";
      say STDERR "This dir contains $RH::Dir::totfcount entries.";
      say STDERR 'List of paths from GetFiles:';
      say STDERR $_->{Path} for @{$curdirfiles};
      say STDERR '';
   }

   # If being "very verbose", append all 15 RH::Dir file-type counters to this program's accumulators:
   if ( $Verbose >= 2 ) {
      $totfcount += $RH::Dir::totfcount; # all files
      $sdircount += $RH::Dir::sdircount; # directories
      $slkdcount += $RH::Dir::slkdcount; # symbolic links to directories
      $linkcount += $RH::Dir::linkcount; # symbolic links to files
      $weircount += $RH::Dir::weircount; # symbolic links to weirdness
      $brkncount += $RH::Dir::brkncount; # symbolic links to nowhere
      $bspccount += $RH::Dir::bspccount; # block special files
      $cspccount += $RH::Dir::cspccount; # character special files
      $pipecount += $RH::Dir::pipecount; # pipes
      $sockcount += $RH::Dir::sockcount; # sockets
      $ottycount += $RH::Dir::ottycount; # tty files
      $hlnkcount += $RH::Dir::hlnkcount; # regular files with multiple hard links
      $regfcount += $RH::Dir::regfcount; # regular files
      $unkncount += $RH::Dir::unkncount; # unknown files
      $noexcount += $RH::Dir::noexcount; # Nonexistent files.
   }

   # Make a hash of refs to lists of refs to file-record hashes, keyed by type:
   my %TypeLists;

   # Autovivify create type arrays in %TypeLists, and to push refs to file-record hashes into those arrays,
   # but only for files matching $Predicate:
   foreach my $file ( @{$curdirfiles} ) {
      ++$filecount;
      local $_ = e $file->{Path};
      if ($Db) {say "dollscore = $_"}
      if ( eval($Predicate) ) {
         if ($Db) {
            say STDERR 'predicate succeeded';
         }
         ++$predcount;
         push @{$TypeLists{$file->{Type}}}, $file;
      }
      else {
         if ($Db) {
            say STDERR 'predicate failed';
         }
      }
   }

   if ($Db) {print Dumper \%TypeLists}

   # Make a list of types:
   my @Types = split //,'DRLWXBCPSTHFUN';

   # Directory Listing (if in inodes mode):
   if ($Inodes)
   {
      say STDOUT 'T: Date:       Time:        Size:     Inode:      L:   Bsize:   Blocks:  Name:';
      foreach my $type (@Types)
      {
         foreach my $file (sort {fc($a->{Name}) cmp fc($b->{Name})} @{$TypeLists{$type}})
         {
            printf STDOUT "%-1s  %-10s  %-11s  %-8.2E  %10d  %3u  %7u  %7u  %-s\n",
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
            printf STDOUT "%-1s  %-10s  %-11s  %-8.2E  %3u  %-s\n",
                          $file->{Type}, $file->{Date},  $file->{Time},
                          $file->{Size}, $file->{Nlink}, $file->{Name};
         }
      }
   }

   # Print stats for this directory:
   dir_stats($curdir);

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

sub dir_stats ($curdir) {
   if ( $Verbose >= 1 ) {
      say STDERR "\nStatistics for directory \"$curdir\":";
      say STDERR "Found ${RH::Dir::totfcount} files in this directory matching given target and regexp.";
   }
   if ( $Verbose >= 2 ) {
      say    STDERR "\nDirectory entries encountered in this directory included:";
      printf STDERR "%7u total files\n",                            $RH::Dir::totfcount;
      printf STDERR "%7u directories\n",                            $RH::Dir::sdircount;
      printf STDERR "%7u symbolic links to directories\n",          $RH::Dir::slkdcount;
      printf STDERR "%7u symbolic links to files\n",                $RH::Dir::linkcount;
      printf STDERR "%7u symbolic links to weirdness\n",            $RH::Dir::weircount;
      printf STDERR "%7u symbolic links to nowhere\n",              $RH::Dir::brkncount;
      printf STDERR "%7u block special files\n",                    $RH::Dir::bspccount;
      printf STDERR "%7u character special files\n",                $RH::Dir::cspccount;
      printf STDERR "%7u pipes\n",                                  $RH::Dir::pipecount;
      printf STDERR "%7u sockets\n",                                $RH::Dir::sockcount;
      printf STDERR "%7u tty files\n",                              $RH::Dir::ottycount;
      printf STDERR "%7u regular files with multiple hard links\n", $RH::Dir::hlnkcount;
      printf STDERR "%7u regular files\n",                          $RH::Dir::regfcount;
      printf STDERR "%7u files of unknown type\n",                  $RH::Dir::unkncount;
      printf STDERR "%7u non-existent directory entries\n",         $RH::Dir::noexcount;
   }
   return 1;
} # end sub dir_stats ($curdir)

sub tree_stats {
   if ( $Verbose >= 1 ) {
      say STDERR "\nStatistics for this tree:";
      say STDERR "Navigated $direcount directories.";
      say STDERR "Found $filecount files matching given target and regexp.";
      say STDERR "Found $predcount files also matching given predicate.";

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

sub error ($NA)
{
   print STDERR ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: rhdir.pl takes 0, 1, or 2 arguments, but you typed $NA arguments.
   Help follows:
   END_OF_ERROR
} # end sub error ($NA)

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

   Unusually for my programs, this program has 3 verbosity levels:
   Level 0 - "Quiet"
   Level 1 - "Terse" (DEFAULT)
   Level 2 - "Verbose"

   At verbosity Level 0, this program will print matching file paths only.
   At verbosity Level 1, basic statistics will also be printed.
   At verbosity Level 2, counts of all file types encounters are also printed.

   -------------------------------------------------------------------------------
   Command lines:

   rhdir.pl [-h | --help]            (to print this help and exit)
   rhdir.pl [options] [Arguments]    (to list directory entries  )

   -------------------------------------------------------------------------------
   Description of options:

   Option:             Meaning:
   -h or --help        Print help and exit.
   -e or --debug       Print diagnostics.
   -q or --quiet       Be  non-verbose (don't list stats or counts).
   -t or --terse       Be semi-verbose (list stats  but not counts).     (DEFAULT)
   -v or --verbose     Be VERY-verbose (list both stats AND counts).
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
