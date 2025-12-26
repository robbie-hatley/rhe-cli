#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# dedup-files.pl
# This program finds and unlinks duplicate files in the current directory (and all of its subdirectories if
# a -r or --recurse option is used).
#
# This program works by making a list of all files encountered in each subdirectory, ordered by size.
# Within each size group, it compares each file to all the files to its right. For each pair of duplicate
# files it finds, it gives the user these choices:
#
# 1. Erase first file.
# 2. Erase second file.
# 3. Ignore this pair of duplicate files and move to next.
# 4. Quit.
# 5. Enter no-prompt mode and erase all newer duplicates without prompting.
#
# This program was written by Robbie Hatley, starting 2005-06-21, as a "learn Perl" exercise.
#
# Edit History:
# Tue Jun 21, 2005: Started writing it.
# Thu Nov 20, 2014: Getting back to this exercise after 9-year hiatus.
# Mon Nov 24, 2014: Got it working up to the point of alerting user as to whether each pair of same-size
#                   files are identical or different.
# Thu Dec 04, 2014: Now fully functional.
# Wed Dec 10, 2014: Found and fixed a bug which was causing some files to be flagged as duplicates even
#                   though they weren't. This was caused by not resetting the read pointer on file 1
#                   before trying to compare it to file 2. I fixed this bug by moving the open() statements
#                   to just before start of BUFFER loop, and moving the close() statements to just after end
#                   of the BUFFER loop, and adding seek($fh, 0, 0) statements to just before the BUFFER loop,
#                   to make sure the read pointers were 0.
# Sat Dec 13, 2014: Added inodes to collection of info. To-do: I need to check whether file 1 is an "alias"
#                   for file 2 (same inode).
# Fri Mar 20, 2015: I went through and tightened things up based on things I've learned recently. For one
#                   thing, I declared all of the global variables up front with "our", and got rid of the ugly
#                   "$::varname" syntax, and cleaned up messy syntax for addressing elements of file records.
# Mon Mar 23, 2015: Merged counter initializations to declarations. Added $regucount.
# Sun Apr 12, 2015: I changed the two main counters in RH::Dir to $totfcount & $regfcount, and I made local
#                   copies in this file's package, NOT aliased to the ones in RH::Dir, so that I can grab
#                   snapshots immediately after any call to a "get files" function in RH::Dir.
# Fri Apr 24, 2015: Made many changes. Added options, help, recursion, etc. Also renamed script to "ddf".
# Wed May 13, 2015: Changed Help from multiple say's littered with single and double quotes to a
#                   "Here Document" format.
# Thu Jul 09, 2015: Made corrections to ensure correct handling of incoming utf8 data from all sources.
# Fri Jul 17, 2015: Further upgraded for utf8.
# Thu Apr 14, 2016: Now using -CSDA.
# Fri Apr 15, 2016: Added no-prompt mode, and did some refactoring to cut size of over-lengthy sub
#                   "process_current_directory". Added subs "erase_newer" and "dup_prompt".
# Thu Jul 11, 2018: Now has "Spotlight" mode for deduping Windows 10 "Spotlight" photos.
# Wed Mar 11, 2020: Added sub "erase_older" for Spotlight purposes. Also changed spotlight to prefer
#                   64-character "spotlight" names over 8-character "gibberish" names. Also created sub
#                   "annotate_file" which adds a spotlight name to the name of an identical non-spotlight-name
#                   file, like so:
#                   File1 old name: Green-Pasture.jpg
#                   File2     name: 620b14e79a353f16.jpg
#                   File1 new name: Green-Pasture(620b14e79a353f16).jpg
#                   This makes it much easier to look-up files on the "windows10spotlight.com" web site.
# Sun Mar 15, 2020: Found, fixed bug causing crash in newer() / older() selection code (missing braces).
#                   Also, got rid of file "annotation", as it turns out that "windows10spotlight.com" is
#                   using SHA1 hashes rather than Windows Spotlight id strings. Also, spotlight duplicates
#                   now result in unlinking the NEWER file instead of the OLDER file.
# Wed Jul 08, 2020: Removed spurious "Unlinked file" notice in erase_newer, as it duplicates the notices
#                   from unlink_file, and it was resulting in "Unlinked file ***DELETED***" being printed.
# Sat Aug 15, 2020: Cleaned up spotlight logic, and "use v5.30;".
# Sun Jan 10, 2021: Got rid of "Settings" hash. All settings variables are now declared and initialized by
#                   "$main::VarName = DefaultValue;"
# Mon Feb 01, 2021: Widened to 120 characters. Cleaned up comments. Simplified padding of file name field.
# Thu Feb 11, 2021: Got rid of "delete both files" option. Clarified Help. Replaced multiple mode variables
#                   with "$PromptMode". Clarified comments. Now using "use experimental 'switch';".
# Fri Nov 05, 2021: Now presents per-directory stats as well as per-tree stats. In order to do this, I had to
#                   make most functions return result-code strings rather than just return 0 or 1.
# Tue Nov 16, 2021: Got rid of most of the boilerplate; now using common::sense instead. Also, now putting
#                   "double quotes" around names of files presented to user for possible unlinking.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "Sys::Binmode".
# Fri Aug 19, 2022: Clarified comments in spotlight() regarding file-name preferences.
# Fri Jan 06, 2023: Added ability for user to specify WHICH files to dedup via regular expressions. Also added
#                   lots more comments. (Some parts of this program were sorely lacking documentation.)
# Thu Aug 03, 2023: Reduced width from 120 to 110. Got rid of "common::sense" (antiquated). Got rid of all
#                   prototypes; now using signatures instead. Switched from "cwd_utf8" to "d getcwd".
#                   Replaced all given/when with if/elsif/else. Shortened some sub names. Improved help.
#                   Dramatically-simplified argv. Changed brace style to "if (test) {".
# Mon Aug 21, 2023: An "option" is now "one or two hyphens followed by 1-or-more word characters".
#                   Reformatted debug printing of opts and args to ("word1", "word2", "word3") style.
#                   Inserted text into help explaining the use of "--" as "end of options" marker.
# Tue Aug 22, 2023: Fixed missing $" and $, variables (set item separation to ', ').
# Mon Aug 28, 2023: Clarified sub argv().
#                   Got rid of "/...|.../" in favor of "/.../ || /.../" (speeds-up program).
#                   Simplified way in which options and arguments are printed if debugging.
#                   Removed "$" = ', '" and "$, = ', '". Got rid of "/o" from all instances of qr().
#                   Changed all "$db" to $Debug". Debugging now simulates renames instead of exiting in main.
#                   Removed "no debug" option as that's already default in all of my programs.
#                   Changed short option for debugging from "-e" to "-d".
# Wed Aug 14, 2024: Removed unnecessary "use" statements. Changed short option for debug from "-d" to "-e".
# Wed Feb 26, 2025: Trimmed horizontal dividers and reformated over-length comment lines.
# Tue Mar 04, 2025: Now using global "t0" and "BEGIN" block to start timer.
# Sun Apr 27, 2025: Fixed stats bug (due to changes in GetRegularFilesBySize()). Now using "utf8::all" and
#                   "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl". Nixed all "d", "e".
# Tue May 06, 2025: Reverted to "-C63", "utf8", "Cwd", "d", "e", for Cygwin compatibility. Now using Switch.
# Fri Dec 26, 2025: Re-reverted to "#!/usr/bin/env perl", "use utf8::all", "use Cwd::utf8".
#                   Moved from "core" to "util". Deleted "core".
##############################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
use List::Util 'sum0';
use Switch;
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
# NOTE: This program has no variable "$Verbose", because this program requires maximum verbosity, always.
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $OriDir    = cwd       ; # Original directory.       cwd       Directory on program entry.
my $Target    = 'A'       ; # Target                    F|D|B|A   Target all directory entries.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.

# Modes:
my $PromptMode = 0 ; # Prompting Mode. 0 => DupPrompt (ask user what to do)
                     #                 1 => Spotlight (process Spotlight files)
                     #                 2 => NoPrompt  (act without prompting user)
my $PrejudMode = 0 ; # Prejudice Mode. 0 => Newer     (erase newer duplicates)
                     #                 1 => Older     (erase older duplicates)

# Hashes:
my %PromptHash = ( 0 => 'DupPrompt' , 1 => 'Spotlight' , 2 => 'NoPrompt' );
my %PrejudHash = ( 0 => 'Newer'     , 1 => 'Older'                       );

# RegExps:
my $shapat = qr(^[0-9a-f]{40}(?:-\(\d{4}\))?(?:\.\w+)?$); # SHA1 hash pattern
my $gibpat = qr(^[a-z]{8}(?:-\(\d{4}\))?(?:\.\w+)?$)    ; # Gibberish pattern
my $wslpat = qr(^[0-9a-f]{64}(?:-\(\d{4}\))?(?:\.\w+)?$); # Windows SpotLight pattern

# Per-Directory Counters:
my $filedirec = 0; # Count of regular files processed.
my $compdirec = 0; # Count of comparisons of file pairs.
my $dupldirec = 0; # Count of duplicate file pairs found.
my $ignodirec = 0; # Count of ignored duplicate file pairs.
my $deledirec = 0; # Count of deleted files.
my $faildirec = 0; # Count of failed attempts at deleting files.
my $errodirec = 0; # Count of errors.
my $simudirec = 0; # Count of simulated file unlinkages.

# Per-Tree Counters:
my $direcount = 0 ; # Count of directories processed by curdire().
my $filecount = 0 ; # Count of files matching target, regexp, and predicate.
my $compcount = 0 ; # Count of comparisons of file pairs.
my $duplcount = 0 ; # Count of duplicate file pairs found.
my $ignocount = 0 ; # Count of ignored duplicate file pairs.
my $delecount = 0 ; # Count of deleted files.
my $failcount = 0 ; # Count of failed attempts at deleting files.
my $errocount = 0 ; # Count of errors.
my $simucount = 0 ; # Count of simulated file unlinkages.

# Note regarding settings:

# Default values:
# The "0" value for each of the above settings is the "default" setting, which may be overridden by
# command-line options or by this program itself. (Well, except for $RegExp, which has default qr/^.+$/o
# which means "process all file names".)

# File selection:
# The target type is set to 'F' for "regular files only" and this never changes. The file-name specification
# is initially set to "all file names", but this can be over-ridden by using an argument, which must be
# a Perl-compliant regular expression describing which file names to process.

# Prompting Modes:
# This program is always in 1 of 3 prompting modes: DupPrompt, Spotlight, or NoPrompt.
# DupPrompt Mode asks the user what to do before taking any action.
# Spotlight Mode takes some actions without asking, but if it has a question, it switches to DupPrompt Mode.
# NoPrompt  Mode does whatever the fuck it thinks best and doesn't ask the user a goddamn thing.

# Prejudice Modes:
# NoPrompt Mode can operate in either of 2 file-age prejudice modes: "newer" or "older".
# "newer" prejudice discriminates against newer files.
# "older" prejudice discriminates against older files.
# These prejudices don't affect Spotlight Mode or DupPrompt mode.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv        ; # Use contents of @ARGV to set settings.
sub curdire     ; # Process the files of the current directory.
sub dup_prompt  ; # DupPrompt Mode (asks user what to do).
sub spotlight   ; # Spotlight Mode (for processing Microsoft Windows Spotlight photos).
sub no_prompt   ; # NoPrompt  Mode (does whatever it damn well pleases, fuck you very much).
sub erase_newer ; # Erases the newer of a pair of identical files by calling unlink_file().
sub erase_older ; # Erases the older of a pair of identical files by calling unlink_file().
sub unlink_file ; # Unlink a file.
sub print_two   ; # Print two file names, with times and dates, aligned.
sub BLAT        ; # Print messages only if debugging.
sub dire_stats  ; # Print statistics for current directory.
sub tree_stats  ; # Print statistics for current tree.
sub error       ; # Print error message.
sub help        ; # Print help  message.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Start execution timer:
   my $t0 = time;
   my @s0 = localtime($t0);

   # Process @ARGV and set settings:
   argv;

   # If debugging, print the values of all variables except counters, after processing @ARGV:
   if ( $Debug >= 1 ) {
      say STDERR 'Debug msg in dedup-files: Values of variables after calling argv():';
      say STDERR "pname     = $pname";
      say STDERR "cmpl_beg  = $cmpl_beg";
      say STDERR "cmpl_end  = $cmpl_end";
      say STDERR "Options   = (@Opts)";
      say STDERR "Arguments = (@Args)";
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR "OriDir    = $OriDir";
      say STDERR "Recurse   = $Recurse";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR "Prompt md = $PromptHash{$PromptMode}" ;
      say STDERR "Prejud md = $PrejudHash{$PrejudMode}" ;
      say STDERR '';
   }

   # Print program entry messages:
   printf STDERR "Now entering program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n\n",
                 $s0[2], $s0[1], $s0[0], 1+$s0[4], $s0[3], 1900+$s0[5];
   printf STDERR "Compilation time was %.3fms\n\n",
                 1000 * ($cmpl_end - $cmpl_beg);
   say STDERR 'Basic settings:';
   say STDERR "OriDir    = $OriDir"                  ;
   say STDERR "Recurse   = $Recurse"                 ;
   say STDERR "Target    = $Target"                  ;
   say STDERR "RegExp    = $RegExp"                  ;
   say STDERR "Predicate = $Predicate"               ;
   say STDERR "prompt md = $PromptHash{$PromptMode}" ;
   say STDERR "prejud md = $PrejudHash{$PrejudMode}" ;
   say STDERR '';

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   if ($Help) {help}
   else {
      if ($Recurse) {
         my $mlor = RecurseDirs {curdire};
         say "\nMaximum levels of recursion reached = $mlor";
      }
      else {curdire}
      tree_stats;
   }

   # Stop execution timer:
   my $t1 = time;
   my @s1 = localtime($t1);

   # Print exit messages:
   my $te = $t1 - $t0; my $ms = 1000 * $te;
   printf STDERR "\nNow exiting program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n",
                 $s1[2], $s1[1], $s1[0], 1+$s1[4], $s1[3], 1900+$s1[5];
   printf STDERR "Execution time was %.3fms.\n", $ms;

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
      /^-$s*h/ || /^--help$/      and $Help       = 1  ;
      /^-$s*e/ || /^--debug$/     and $Debug      = 1  ;
      /^-$s*l/ || /^--local$/     and $Recurse    = 0  ; # Default.
      /^-$s*r/ || /^--recurse$/   and $Recurse    = 1  ;
      /^-$s*s/ || /^--spotlight$/ and $PromptMode = 1  ;
      /^-$s*n/ || /^--newer$/     and $PromptMode = 2 and $PrejudMode = 0;
      /^-$s*o/ || /^--older$/     and $PromptMode = 2 and $PrejudMode = 1;
   }

   # NOTE: There are no verbosity controls in this program, because this program requires maximum verbosity
   # always, because of its inherently highly-interactive nature.

   # NOTE: Likewise, there are no target controls, because this program processes data files only.

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

   # Get and announce current working directory:
   my $cwd = cwd;
   say '';
   say "Dir # $direcount: \"$cwd\"";

   # Get hash of arrays of file records for for all regular files
   # in current directory, keyed by size:
   my $curdirfiles = GetRegularFilesBySize($cwd, $RegExp, $Predicate);

   # Increment file counters:
   $filedirec += $RH::Dir::totfcount;
   $filecount += $RH::Dir::totfcount;

   # Iterate through the keys of the hash, in inverse order of size:
   my @sizes = sort {$b<=>$a} keys %{$curdirfiles};
   SIZE: foreach my $size (@sizes) {
      # How many files in this size group?
      my $count = scalar @{$curdirfiles->{$size}};

      # If fewer than two files exist of this size, go to next size group:
      next SIZE if ($count < 2);

      # "FIRST" LOOP: Iterate through all files of current size except last:
      FIRST: foreach my $i (0..$count-2) {
         # Set $file1 to reference to first file record:
         my $file1 = $curdirfiles->{$size}->[$i];

         # "SECOND" LOOP: Iterate through all files of current size which are
         # to the right of file "$i":
         SECOND: foreach my $j ($i+1..$count-1) {
            # Set $file2 to reference to second file record:
            my $file2 = $curdirfiles->{$size}->[$j];
            BLAT "\n"
                ."Debug msg in dedup-files, in curdire(), in SECOND:\n"
                ."FIRST  file name = $file1->{Name}\n"
                ."SECOND file name = $file2->{Name}";

            # Skip to next FIRST file if $file1 has already been deleted.
            #
            # Note: This MUST be HERE, and NOT above start of "SECOND" loop,
            # because actions taken in "SECOND" loop may CAUSE the "FIRST" file
            # to become "***DELETED***" or "***FAILED***".
            #
            # Note: Don't take any actions, return anything, or count anything
            # at this point, because we're just skipping-over the remains of
            # situations which have ALREADY been noted and acted-on.
            # Only print anything if debugging:
            if ( $file1->{Name} eq '***DELETED***' ) {
               BLAT "FIRST file was deleted. Name = $file1->{Name}";
               next FIRST;
            }
            if ( $file1->{Name} eq '***FAILED***' ) {
               BLAT "FIRST file was failed. Name = $file1->{Name}";
               next FIRST;
            }
            if ( $file1->{Name} eq '***SIMULATED***' ) {
               BLAT "FIRST file was simulated. Name = $file1->{Name}";
               next FIRST;
            }

            # Skip to next SECOND file if $file2 has already been deleted:
            #
            # Note: Don't take any actions, return anything, or count anything
            # at this point, because we're just skipping-over the remains of
            # situations which have ALREADY been noted and acted-on.
            # Only print anything if debugging:
            if ( $file2->{Name} eq '***DELETED***' ) {
               BLAT "SECOND file was deleted. Name = $file2->{Name}";
               next SECOND;
            }
            if ( $file2->{Name} eq '***FAILED***' ) {
               BLAT "SECOND file was failed. Name = $file2->{Name}";
               next SECOND;
            }
            if ( $file2->{Name} eq '***SIMULATED***' ) {
               BLAT "SECOND file was simulated. Name = $file2->{Name}";
               next SECOND;
            }

            # If files i and j have same inode, they're just aliases for the
            # same file, so move on to next second file:
            next SECOND if $file1->{Inode} == $file2->{Inode};

            # Do files have identical content?
            my $identical = RH::Dir::FilesAreIdentical($file1->{Name}, $file2->{Name});

            # If FilesAreIdentical didn't die, we successfully compared the
            # current pair of files, so increment "$compdirec" and "$compcount":
            ++$compdirec;
            ++$compcount;

            # If we found no difference between these two files,
            # then they're duplicates. If in no-prompt mode, erase
            # the newer file without prompting; otherwise, present
            # options to user:
            if ($identical) {
               # Announce identicality:
               printf("\nThese two files are identical:\n");

               # Print info on both files, aligned:
               print_two($file1,$file2);

               # Warn user if files are empty:
               if (0 == $file1->{Size}) {
                  say "Note: Files contain 0 bytes of data.";
               }

               # Increment $dupldirec and $duplcount:
               ++$dupldirec;
               ++$duplcount;

               # Create a "result" variable to hold the result of processing pair of duplicate files:
               my $result = '';

               # Call appropriate subroutine (depending on value of $PromptMode) and store result in $result:
               switch ($PromptMode) {
                  case 0 {$result = dup_prompt($file1, $file2)} # DupPrompt mode
                  case 1 {$result = spotlight ($file1, $file2)} # Spotlight mode
                  case 2 {$result = no_prompt ($file1, $file2)} # NoPrompt  mode
                  # Otherwise, we're in an unknown prompt mode; this is a fatal error, so die:
                  else {die "Fatal error in \"dedup-files.pl\": Invalid prompt mode in curdire.\n$!\n"}
               }

               # We just finished processing a pair of identical files.
               # The result of that was "ignored", "deleted", "failed", "error", "exit", or "simulated".
               # Increment counters (and maybe exit program) accordingly:
               switch ($result) {
                  case 'ignored'   {++$ignodirec;++$ignocount}
                  case 'deleted'   {++$deledirec;++$delecount}
                  case 'failed'    {++$faildirec;++$failcount}
                  case 'error'     {++$errodirec;++$errocount}
                  case 'exit'      {dire_stats;tree_stats;exit 0}
                  case 'simulated' {++$simudirec;++$simucount}
                  # Otherwise, we received an unknown result code; this is a fatal error, so die:
                  else {die "Fatal error in \"dedup-files.pl\": Invalid result code in curdire.\n$!\n"}
               }
            } # end if identical
            else { # if not identical
               say "\nThese two files are same-size but different:";
               print_two($file1,$file2);
            } # end if not identical
         } # end SECOND file loop
      } # end FIRST file loop
   } # end SIZE group loop

   if ($Debug) {
      # Did we ACTUALLY mark any files as being deleted or failed?
      foreach my $size (sort {$b<=>$a} keys %{$curdirfiles}) {
         # Say the names of all of the files in this size group:
         say '';
         say "Files of size $size:";
         say $_->{Name} for (@{$curdirfiles->{$size}});
      }
      say '';
   }
   dire_stats;
   return 1;
} # end sub curdire

# Mode 0 (DupPrompt = "Ask user what to do."):
sub dup_prompt ($file1, $file2) {
   # Get a keystroke from user:
   while (42) {
      # Ask user what to do:
      print("Type 1 to unlink \"$file1->{Name}\"\n");
      print("Type 2 to unlink \"$file2->{Name}\"\n");
      print("Type 3 to ignore these duplicates\n");
      print("Type 4 to enter no-prompt mode and unlink all newer duplicates\n");
      print("Type 5 to enter no-prompt mode and unlink all older duplicates\n");
      print("Type 6 to end program and return to bash\n");
      my $char = RH::Util::get_character;
      if ('1' eq $char) { # DELETE FIRST FILE
         return unlink_file($file1); # Unlink first file.
      }

      elsif ('2' eq $char) { # DELETE SECOND FILE
         return unlink_file($file2); # Unlink second file.
      }

      elsif ('3' eq $char) { # IGNORE THIS PAIR OF DUPLICATES
         say "Ignoring these duplicates.";
         return 'ignored';
      }

      elsif ('4' eq $char) { # ERASE ALL NEWER DUPLICATES WITHOUT PROMPTING
         say "Entering no-prompt mode and erasing all newer duplicates.";
         $PromptMode = 2;
         $PrejudMode = 0;
         return erase_newer ($file1, $file2);
      }

      elsif ('5' eq $char) { # ERASE ALL OLDER DUPLICATES WITHOUT PROMPTING
         say "Entering no-prompt mode and erasing all older duplicates.";
         $PromptMode = 2;
         $PrejudMode = 1;
         return erase_older ($file1, $file2);
      }

      elsif ('6' eq $char) { # COMPUTER, END PROGRAM
         say "Ending program, by your command.";
         return 'exit';
      }

      elsif ( ! defined $char ) { # OOPSIE!
         warn "Error in \"dedup-files.pl\":\n"
            . "get_character returned undef.\n"
            . "$!\n"
            . "Continuing execution, but if this keeps happening,\n"
            . "consider aborting the program using Ctrl-C.\n";
         return 'error';
      }

      else {
         say "Invalid key.";
         # NOTE: Don't return here; that way execution continues at top of while() loop.
      }
   } # end while (42) {get keystroke from user}
} # end sub dup_prompt (MODE 0)

# Mode 1 (Spotlight = "Process Microsoft Windows Spotlight scenic photographs."):
sub spotlight ($file1, $file2) {
   # Prefered order of names for Windows 10 Spotlight scenic photographs is
   # 1. Descriptive names
   # 2. SHA1-hash names (40 hexadecimal digits)
   # 3. Gibberish names (8 lower-case letters)
   # 4. Windows-Spotlight names (64 hexadecimal digits)
   # So, we attempt to get rid of the least-desirable types of file names first,
   # then the next-least-desirable,
   # then the next-next-least-desirable,
   # and if all else fails, ask user what to do:

   # WSL + NON-WSL:
   if ($file1->{Name} =~ $wslpat && $file2->{Name} !~ $wslpat) {
      return unlink_file($file1); # Unlink first file.
   }

   # NON-WSL + WSL:
   elsif ($file1->{Name} !~ $wslpat && $file2->{Name} =~ $wslpat) {
      return unlink_file($file2); # Unlink second file.
   }

   # GIB + NON-GIB:
   elsif ($file1->{Name} =~ $gibpat && $file2->{Name} !~ $gibpat) {
      return unlink_file($file1); # Unlink first file.
   }

   # NON-GIB + GIB:
   elsif ($file1->{Name} !~ $gibpat && $file2->{Name} =~ $gibpat) {
      return unlink_file($file2); # Unlink second file.
   }

   # SHA + NON-SHA:
   elsif ($file1->{Name} =~ $shapat && $file2->{Name} !~ $shapat) {
      return unlink_file($file1); # Unlink first file.
   }

   # NON-SHA + SHA:
   elsif ($file1->{Name} !~ $shapat && $file2->{Name} =~ $shapat) {
      return unlink_file($file2); # Unlink second file.
   }

   # OTHER + OTHER:
   else {
      say 'Neither file has a gib, wsl, or sha1 name, so entering user-intervention mode.';
      return dup_prompt($file1, $file2);
   }
} # end sub spotlight (MODE 1)

# Mode 2 (NoPrompt = "Erase a duplicate file automatically without prompting the user."):
sub no_prompt ($file1, $file2) {
   if ( 1 == $PrejudMode ) {
      return erase_older($file1, $file2);
   }
   else
   {
      return erase_newer($file1, $file2);
   }
} # end sub no_prompt (MODE 2)

# Erase the newer of a pair of duplicate files (by calling unlink_file()):
sub erase_newer ($file1, $file2) {
   if ( $file1->{Mtime} > $file2->{Mtime} ) { # If file1 is newer,
      return unlink_file($file1);             # unlink file1;
   }
   else {                                     # otherwise,
      return unlink_file($file2);             # unlink file2.
   }
} # end sub erase_newer

# Erase the older of a pair of duplicate files (by calling unlink_file()):
sub erase_older ($file1, $file2) {
   if ( $file1->{Mtime} < $file2->{Mtime} ) { # If file1 is older,
      return unlink_file($file1);             # unlink file1;
   }
   else {                                     # otherwise,
      return unlink_file($file2);             # unlink file2.
   }
} # end sub erase_older

# Unlink a file (leave the data in-situ, but remove this hard link from this directory),
# or if debugging, just SIMULATE unlinking the file:
sub unlink_file ($file) {
   # If debugging, just go through the motions:
   if ( $Debug ) {
      say "Simulation: Would have unlinked file $file->{Name}";
      $file->{Name} = "***SIMULATED***";
      return 'simulated';
   }
   # Otherwise, try to actually unlink the file:
   else {
      my $success = unlink $file->{Name};
      if ( $success ) {
         say "Successfully unlinked $file->{Name}";
         $file->{Name} = "***DELETED***";
         return 'deleted';
      }
      else {
         say "Failed to unlink $file->{Name}";
         say "\$! = $!";
         $file->{Name} = "***FAILED***";
         return 'failed';
      }
   }
} # end sub unlink_file

# Print two file names, with times and dates, aligned:
sub print_two ($file1, $file2) {
   # Get time and date strings for both files:
   my $time1 = time_from_mtime $file1->{Mtime};
   my $time2 = time_from_mtime $file2->{Mtime};
   my $date1 = date_from_mtime $file1->{Mtime};
   my $date2 = date_from_mtime $file2->{Mtime};

   # Set file name field width to max file name length + 2:
   my $nl1 = length($file1->{Name}); # nl1 = Name Length 1.
   my $nl2 = length($file2->{Name}); # nl2 = Name Length 2.
   my $fnw = $nl2 > $nl1 ? $nl2 + 2 : $nl1 + 2 ; # fnw = File-Name Width.

   # Print first file:
   printf "%-${fnw}s%-18s%-10s%d bytes\n", $file1->{Name}, $date1, $time1, $file1->{Size};

   # Print second file:
   printf "%-${fnw}s%-18s%-10s%d bytes\n", $file2->{Name}, $date2, $time2, $file2->{Size};

   return 1;
} # end sub print_two

# Print messages only if debugging:
sub BLAT ($string) {if ($Debug) {say STDERR $string}}

# Print statistics for current directory:
sub dire_stats {
   say '';
   say 'Statistics for this directory:';
   printf("Processed %6d files.\n",                    $filedirec);
   printf("Compared  %6d pairs of files.\n",           $compdirec);
   printf("Found     %6d pairs of duplicate files.\n", $dupldirec);
   printf("Ignored   %6d pairs of duplicate files.\n", $ignodirec);
   printf("Deleted   %6d files.\n",                    $deledirec);
   printf("Failed    %6d file deletion attempts.\n",   $faildirec);
   printf("Suffered  %6d errors.\n",                   $errodirec);
   printf("Simulated %6d file deletions.\n",           $simudirec);
   # Zero all per-directory counters here so they don't accumulate garbage between calls to curdire:
   $filedirec = 0;
   $compdirec = 0;
   $dupldirec = 0;
   $ignodirec = 0;
   $deledirec = 0;
   $faildirec = 0;
   $errodirec = 0;
   $simudirec = 0;
   return 1;
} # end sub dire_stats

# Print statistics for current tree:
sub tree_stats {
   say '';
   say 'Statistics for this tree:';
   printf("Navigated %6d directories.\n",              $direcount);
   printf("Processed %6d files.\n",                    $filecount);
   printf("Compared  %6d pairs of files.\n",           $compcount);
   printf("Found     %6d pairs of duplicate files.\n", $duplcount);
   printf("Ignored   %6d pairs of duplicate files.\n", $ignocount);
   printf("Deleted   %6d duplicate files.\n",          $delecount);
   printf("Failed    %6d file deletion attempts.\n",   $failcount);
   printf("Suffered  %6d errors.\n",                   $errocount);
   printf("Simulated %6d file deletions.\n",           $simucount);
   return 1;
} # end sub tree_stats

# Handle errors:
sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most 2 optional
   arguments (file-selection regexp and a file-selection predicate).
   Help follows:
   END_OF_ERROR
   return 1;
} # end sub error

# Print help for this program:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "dedup-files.pl", Robbie Hatley's nifty duplicate-file deleter.

   -------------------------------------------------------------------------------
   Command Lines:

   dedup-files.pl [-h|--help]    (to print this help and exit)
   dedup-files.pl [options]      (to find and delete duplicate files)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:             Meaning:
   -h or --help        Print help and exit.
   -e or --debug       Print diagnostics and simulate deletions.
   -l or --local       DON'T recurse subdirectories. (DEFAULT)
   -r or --recurse     DO    recurse subdirectories.
   -s or --spotlight   Enter Spotlight mode (erase gibberish names).
   -n or --newer       Erase all newer duplicates without prompting.
   -o or --older       Erase all older duplicates without prompting.
         --            End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -re to recursively simulate deletions.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: hdonsrl.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Modes of Operation:

   By default, dedup-files starts in "DupPrompt" (interactive) mode and does not
   automatically unlink any file without first asking you what to do.
   In interactive mode, for each pair of duplicates files found, dedup-files
   gives you these 6 choices:

   1. Unlink first  file.
   2. Unlink second file.
   3. Ignore this pair of duplicate files and move on to next.
   4. Enter no-prompt mode and unlink all newer duplicates.
   5. Enter no-prompt mode and unlink all older duplicates.
   6. End program and return to BASH.

   So, using dedup-files you can trim duplicates from your file collection with
   surgical precision, if that's what you want to do. (Or, you can destroy them
   all at once with an atomic bomb, if THAT'S what you want to do. Read on.)

   If you use a "-s" or "--spotlight" option, dedup-files goes into "Spotlight"
   mode and automatically unlinks duplicate files in cases where one of a pair
   of duplicate files has a name which is clearly less-preferred than the other.
   WSL names are preffered over GIB names; SHA1 names are preffered over WSL
   names; and descriptive names are prefered over SHA1 names. If dedup-files
   can't figure out what to do while in Spotlight mode, it switches to DupPrompt
   mode and asks you what to do.

   if you use a "-n", or "--newer" option, dedup-files will erase all newer
   duplicate files in the current directory (and all subdirectories as well
   if a "-r" or "--recurse" option was also used) without prompting.
   BE CAREFUL, because if you say "dedup-files.pl -rn", this program may erase
   a large number of files without stopping to ask for your permission. If that's
   not what you want to do, it's better to run dedup-files in interactive mode.

   if you use a "-o", or "--older" option, dedup-files will erase all older
   duplicate files in the current directory (and all subdirectories as well
   if a "-r" or "--recurse" option was also used) without prompting.
   BE CAREFUL, because if you say "dedup-files.pl -ro", this program may erase
   a large number of files without stopping to ask for your permission. If that's
   not what you want to do, it's better to run dedup-files in interactive mode.

   -------------------------------------------------------------------------------
   Simulation Mode:

   If you use a "-e" or "--debug" option, this program not only prints diagnostics
   but also goes into "Simulation Mode". Everything will work normally right up to
   the point where this program would have deleted a file, then it just SIMULATES
   the deletion without actually deleting anything.

   Thus "--debug" is not primarily for debugging this program (leave that to me),
   but rather, for debugging the way you go about finding and deleting files.
   Are you unsure what deletions would result from a certain set of options and
   arguments? Then use "--debug" Simulation Mode to find out without risking
   unwanted file deletions.

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
