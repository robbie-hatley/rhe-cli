#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# /rhe/scripts/util/dedup-newsbin-files.pl
# "DeDup Newsbin Files"
# Gets rid of duplicate files within file name groups having same base name but different "numerators", where
# a "numerator" is a substring of the form "-(3856)" at the end of the prefix of a file name, and where a
# "base" is a name as it would be if it had no numerators. For example, the "base" of file name
# "Fred-(8874).jpg" is "Fred.jpg".
# Edit history:
# Mon Jun 08, 2015: Wrote it.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory as
#                   its first argument, target as second, and regexp (instead of wildcard) as third.
# Tue Jul 13, 2021: Now 120 characters wide.
# Sat Jul 31, 2021: Now using "use Sys::Binmode" and "e".
# Wed Nov 16, 2021: Now using "use common::sense;".
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate.
# Tue Mar 14, 2023: Added options for local, recursive, quiet, and verbose.
# Thu Aug 03, 2023: Upgraded from "use v5.32;" to "use v5.36;". Got rid of "common::sense" (antiquated).
#                   Went from "cwd_utf8" to "d getcwd". Got rid of prototypes. Changed defaults from "verbose"
#                   and "recurse" to "quiet" and "local". Reduced width from 120 to 110. Shortened sub names.
#                   Got rid of "-l", "--local", "-q", and "--quiet" options as they're already default.
#                   Improved help.
# Mon Aug 21, 2023: An "option" is now "one or two hyphens followed by 1-or-more word characters".
#                   Reformatted debug printing of opts and args to ("word1", "word2", "word3") style.
#                   Inserted text into help explaining the use of "--" as "end of options" marker.
# Tue Aug 22, 2023: Added options for quiet, terse, and local, to complement verbose and recurse.
#                   Added missing sub "error". (What the heck happened to THAT??? It got erased somehow.)
#                   Fixed missing $" and $, variables (set item separation to ', ').
# Mon Aug 28, 2023: Clarified sub argv().
#                   Got rid of "/...|.../" in favor of "/.../ || /.../" (speeds-up program).
#                   Simplified way in which options and arguments are printed if debugging.
#                   Removed "$" = ', '" and "$, = ', '". Got rid of "/o" from all instances of qr().
#                   Changed all "$db" to $Db". Debugging now simulates renames instead of exiting in main.
#                   Removed "no debug" option as that's already default in all of my programs.
#                   Changed short option for debugging from "-e" to "-d".
# Wed Aug 14, 2024: Removed unnecessary "use" statements. Changed short option for debug from "-d" to "-e".
# Tue Mar 04, 2025: Now using global "t0" and "BEGIN" block to start timer.
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e".
# Tue May 06, 2025: Reverted to "-C63", "utf8", "Cwd", "d", "e", for Cygwin compatibility. Now using Switch.
#                   Modernized, with much content imported from latest "core-template.pl".
# Fri Dec 26, 2025: Re-reverted to "#!/usr/bin/env perl", "use utf8::all", "use Cwd::utf8".
#                   Moved from "core" to "util". Deleted "core".
# Sun Jan 18, 2026: Added provision for checking if $OriDir is actually valid (because I've seen that in some
#                   edge cases it may not be!); now also doing RH::Dir debugging if doing local debugging.
# Fri Jan 23, 2026: Improved help().
##############################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
use Switch;
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
# NOTE: There's no variable "$Target" because this program processes data files only.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.
my $OriDir    = cwd       ; # Original directory.       cwd       Directory on program entry.

# Counters:
my $direcount = 0         ; # Count of directories processed by curdire().
my $filecount = 0         ; # Count of files matching target, regexp, and predicate.
my $ngrpcount = 0         ; # Count of name groups found.
my $compcount = 0         ; # Count of pairs of files compared.
my $duplcount = 0         ; # Count of pairs of duplicate files found.
my $delecount = 0         ; # Count of successful file deletions.
my $failcount = 0         ; # Count of failed attempts at deleting files.
my $simucount = 0         ; # Count of simulated file deletions.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
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
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
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
         stats;
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
      /^-$s*h/ || /^--help$/      and $Help    = 1;
      /^-$s*e/ || /^--debug$/     and $Debug   = 1;
      /^-$s*q/ || /^--quiet$/     and $Verbose = 0;
      /^-$s*t/ || /^--terse$/     and $Verbose = 1; # Default.
      /^-$s*v/ || /^--verbose$/   and $Verbose = 2;
      /^-$s*l/ || /^--local$/     and $Recurse = 0; # Default.
      /^-$s*r/ || /^--recurse$/   and $Recurse = 1;
   }
   # NOTE: There are no target controls, because this program processes data files only.

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
   my $cwd = cwd;

   # Announce current working directory if being verbose:
   if ( $Verbose >= 2 ) {
      say STDERR "\nDirectory # $direcount: $cwd\n";
   }

   # Get reference to array of references to file records for all regular files
   # matching $RegExp in current directory:
   my $files = GetFiles($cwd, 'F', $RegExp, $Predicate);

   # Make a hash of references to arrays of references to file records,
   # with the outer hash keyed by name base:
   my %name_groups;
   foreach my $file (@{$files}) {
      ++$filecount;
      my $name = $file->{Name};
      my $base = denumerate_file_name($name);
      push @{$name_groups{$base}}, $file;
   }

   # Iterate through each name group:
   BASE: foreach my $base (sort keys %name_groups) {
      ++$ngrpcount;

      # How many files are in this name-base group?
      my $count = scalar @{$name_groups{$base}};

      # If fewer than two files exist in this name group, go to next name group:
      next BASE if ($count < 2);

      # "FIRST" LOOP: Iterate through all files of current name group except the last:
      FIRST: for my $i (0..$count-2) {
         # Set $file1 to reference to ith file record:
         my $file1 = $name_groups{$base}->[$i];

         # Skip to next first file if file is marked simulated, deleted, or error:
         next FIRST if $file1->{Name} eq "***SIMULATED***";
         next FIRST if $file1->{Name} eq "***DELETED***";
         next FIRST if $file1->{Name} eq "***ERROR***";

         # "SECOND" LOOP: Iterate through all files of current name group which are
         # to the right of file "$i":
         SECOND: for my $j ($i+1..$count-1) {
            # Set $file2 to reference to jth file record:
            my $file2 = $name_groups{$base}->[$j];

            # Skip to next second file if file is marked simulated, deleted, or error:
            next SECOND if $file2->{Name} eq "***SIMULATED***";
            next SECOND if $file2->{Name} eq "***DELETED***";
            next SECOND if $file2->{Name} eq "***ERROR***";

            BLAT "\n"
                ."Debug msg from dnf, curdire(), SECOND:\n"
                ."FIRST  name: $file1->{Name}\n"
                ."SECOND name: $file2->{Name}";

            # Skip to next second file unless jth file is same size as ith file:
            next SECOND unless $file2->{Size} == $file1->{Size};

            # If files i and j have same inode, they're just aliases for the same
            # file, so move on to next second file:
            next SECOND if $file1->{Inode} == $file2->{Inode};

            # Do files have identical content?
            my $identical = FilesAreIdentical($file1->{Name}, $file2->{Name});

            # If FilesAreIdentical didn't die, we successfully compared the current
            # pair of files, so increment "$compcount":
            ++$compcount;

            # If we found no difference between these two files, they're duplicates,
            # so erase the newer file:
            if ($identical) {
               # These files are duplicates, so increment $duplcount:
               ++$duplcount;

               # If file2 has the more-recent Mtime, erase file2:
               if ($file2->{Mtime} > $file1->{Mtime}) {
                  # If debugging, just simulate:
                  if ( $Debug ) {
                     say STDOUT "Simulated erasure: $file2->{Path}";
                     $file2->{Name} = "***SIMULATED***";
                     ++$simucount;
                  }
                  # Otherwise, attempt an actual erasure:
                  else {
                     unlink $file2->{Path} # Unlink second file.
                     and say STDOUT "Erased $file2->{Path}"
                     and $file2->{Name} = "***DELETED***"
                     and ++$delecount
                     or  say STDOUT "Error in dnf: Failed to unlink $file2->{Path}."
                     and $file2->{Name} = "***ERROR***"
                     and ++$failcount;
                  }
                  next SECOND;
               }#end if (erase file 2)

               # Otherwise, erase file1:
               else {
                  # If debugging, just simulate:
                  if ( $Debug ) {
                     say STDOUT "Simulated erasure: $file1->{Path}";
                     $file1->{Name} = "***SIMULATED***";
                     ++$simucount;
                  }
                  # Otherwise, attempt an actual erasure:
                  else {
                     unlink $file1->{Path} # Unlink first file.
                     and say STDOUT "Erased $file1->{Path}"
                     and $file1->{Name} = "***DELETED***"
                     and ++$delecount
                     or  say STDOUT "Error in dnf: Failed to unlink $file1->{Path}."
                     and $file1->{Name} = "***ERROR***"
                     and ++$failcount;
                  }
                  next FIRST;
               }#end else (erase file 1)
            }#end if ($identical)
         }#end SECOND loop
      }#end FIRST loop
   }#end BASE loop
   return 1;
}#end sub curdire

# Print messages only if debugging:
sub BLAT ($string) {if ($Debug) {say STDERR $string}}

# Print statistics:
sub stats {
   # If being terse or verbose, print stats for this program run:
   if ( $Verbose >= 1 ) {
      say    STDERR '';
      say    STDERR "Stats for running program \"$pname\" on dir tree \"$OriDir\":";
      printf STDERR "Navigated   %6d directories.\n",               $direcount;
      printf STDERR "Found       %6d files matching RegExp.\n",     $filecount;
      printf STDERR "Examined    %6d file-name groups.\n",          $ngrpcount;
      printf STDERR "Compaired   %6d pairs of files.\n",            $compcount;
      printf STDERR "Found       %6d pairs of duplicate files.\n",  $duplcount;
      printf STDERR "Deleted     %6d duplicate files.\n",           $delecount;
      printf STDERR "Failed      %6d file deletion attempts.\n",    $failcount;
      printf STDERR "Simulated   %6d file deletions.\n",            $simucount;
   }
   return 1;
} # end sub stats

# Handle errors:
sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most 1 argument,
   which, if present, must be a Perl-Compliant Regular Expression describing
   which file names to check for duplicates. Help follows:
   END_OF_ERROR
   return 1;
} # end sub error

# Print help:
sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "$pname", Robbie Hatley's nifty program for
   erasing duplicate files within groups of files having the same base name but
   different "numerators", where a "numerator" is a substring of the form
   "-(####)" (where the "####" are any 4 digits) immediately before the
   filename's extension (the rightmost dot and all characters to its right).

   For example, say you had files named "Frank.txt", "Frank-(3956).txt", and
   "Frank-(1987).txt", and say that "Frank-(3956).txt" is an older duplicate of
   "Frank.txt", but "Frank-(1987).txt" differs in content from the other two.
   Then dnf would erase "Frank.txt" because it's a newer duplicate, and leave
   the other two files intact because they differ in content.

   By default, this program only processes the current working directory, but
   if a "-r" or "--recurse" option is used, it also processes all
   subdirectories of the current working directory as well.

   -------------------------------------------------------------------------------
   Command lines:

   $pname  [-h|--help]   (to print this help and exit)
   $pname  [options]     (to erase duplicates)

   -------------------------------------------------------------------------------
   Description of options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics and simulate file deletions.
   -q or --quiet      Be quiet.
   -t or --terse      Be terse.                         (DEFAULT)
   -v or --verbose    Be verbose.
   -l or --local      DON'T recurse subdirectories.     (DEFAULT)
   -r or --recurse    DO    recurse subdirectories.
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vre to verbosely and recursively simulate deletions.

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

   Happy duplicate file removing!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
