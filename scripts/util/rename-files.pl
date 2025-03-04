#!/usr/bin/env -S perl -C63

# This is a 110-character-wide UTF-8 Unicode Perl source-code text file with hard Unix line breaks ("\x{0A}").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# rename-files.pl
# Robbie Hatley's Nifty Regular-Expression-Based File Renaming Utility.
# Written by Robbie Hatley.
# Edit history:
# Mon Apr 20, 2015: Started writing it on or about this date.
# Fri Apr 24, 2015: Made many changes. Added options, help, recursal.
# Wed May 15, 2015: Changed Help() to "here document" format.
# Tue Jun 02, 2015: Made various corrections and improvements.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory as
#                   its first argument, target as second, and regexp (instead of wildcard) as third.
# Tue Nov 16, 2021: Now using common::sense, and now using extended regexp sequences instead of regexp
#                   delimiters.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "Sys::Binmode".
# Thu Jul 27, 2023: Heavily refactored. Reduced width from 120 to 110 with github in-mind. Upgraded from
#                   "use v5.32;" to "use v5.36;". Got rid of prototypes. Sub "error" is now "error($NA)".
#                   Single-letter options can now be piled-up after a single hyphen. Got rid of
#                   "common::sense" (antiquated). Sub "error" now prints error message ONLY (doesn't run help
#                   or exit; those are called from argv). Still using obsolete given/when via "experimental".
# Sat Jul 29, 2023: Got rid of all uses of "given" and "when". Also, I'm now sending all printing to STDERR
#                   except for printing each matching path to STDOUT. That way a 1> redirect should print
#                   matching paths only, and a 2> redirect should print diagnostics only.
# Sun Jul 30, 2023: Used hashes of Modes and Targets to print settings at start of program run, fixed
#                   formatting of execution time, and changed default target to "F" instead of "A".
# Mon Jul 31, 2023: Cleaned up formatting and comments. Fine-tuned definitions of "option" and "argument".
#                   Fixed bug in which $, was being set instead of $" .
#                   Got rid of "--target=xxxx" options in favor of just "--xxxx".
#                   Got rid of "--mode=xxxx"   options in favor of just "--xxxx".
# Tue Aug 01, 2023: Improved help.
# Thu Aug 03, 2023: Now using "my $curdir = d getcwd" instead of "my $curdir = cwd_utf8;".
#                   Fixed execution-time bug (wasn't printing "ms"). Improved help.
# Tue Aug 15, 2023: Added "--debug" option. Renamed "rename_files()" to "curdire()". Created sub "curfile()".
#                   All normal-operations printing is now to STDOUT, and all stats, diagnostics, and
#                   unrecoverable errors are to STDERR. Got rid of variable "$Success" (now testing return
#                   of "rename_file" in if() instead).
# Mon Aug 21, 2023: An "option" is now "one or two hyphens followed by 1-or-more word characters".
#                   Reformatted debug printing of opts and args to ("word1", "word2", "word3") style.
#                   Inserted text into help explaining the use of "--" as "end of options" marker.
# Thu Aug 31, 2023: Clarified sub argv().
#                   Got rid of "/...|.../" in favor of "/.../ || /.../" (speeds-up program).
#                   Simplified way in which options and arguments are printed if debugging.
#                   Removed "$" = ', '" and "$, = ', '". Got rid of "/o" from all instances of qr().
#                   Changed all "$db" to $Db". Debugging now simulates renames instead of exiting in main.
#                   Removed "no debug" option as that's already default in all of my programs.
#                   "$Verbose" now means "print directories"; all other info is now printed regardless.
#                   STDERR = "stats and serious errors". STDOUT = "files renamed, and dirs if being verbose".
# Thu Sep 07, 2023: Added $Predicate. Using a predicate argument forces $Target to be 'A' to avoid conflicts.
#                   Fixed "--mode=xxxx" typos in help.
# Mon Oct 09, 2023: Fixed bug in which debug msg in curdire was being printed even when not debugging.
# Sat Apr 27, 2024: Set default target to "both" and improved comments and help.
# Wed Aug 14, 2024: Removed unnecessary "use" statements.
# Mon Oct 07, 2024: Added "use warnings FATAL => 'utf8';". Removed "_END_".
##############################################################################################################

use v5.36;
use utf8;
use warnings FATAL => 'utf8';
use Cwd;
use Time::HiRes 'time';
use RH::Util;
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ;
sub curdire ;
sub curfile ;
sub stats   ;
sub error   ;
sub help    ;

# ======= VARIABLES: =========================================================================================

# Settings:   Default Value:   Meaning of Setting:                Range:         Meaning of default:
my $Db        = 0          ; # Debug?                             bool           Don't debug.
my $Verbose   = 0          ; # Print directories?                 bool           Don't print dirs.
my $Recurse   = 0          ; # Recurse subdirectories?            bool           Be local.
my $Target    = 'B'        ; # Files, directories, both, or All?  F|D|B|A        Both files & dirs.
my $Mode      = 'P'        ; # Prompt mode                        P|S|Y          Prompt user.
my $RegExp    = qr/^(.+)$/ ; # RegExp.                            RegExp         Match all file names.
my $Replace   = '$1'       ; # Replacement string.                string         Replacement is same as match.
my $Flags     = ''         ; # Flags for s/// operator.           imsxopdualgre  No flags.
my $Predicate = 1          ; # Boolean file-test predicate.       bool           All file-type combos.

# Counters:
my $dircount  = 0; # Count of directories processed.
my $filecount = 0; # Count of files matching target and regexp.
my $predcount = 0; # Count of files also matching $Predicate.
my $samecount = 0; # Count of files for which NewName eq OldName.
my $diffcount = 0; # Count of files for which NewName ne OldName.
my $skipcount = 0; # Count of files skipped at user's request.
my $renacount = 0; # Count of files successfully renamed.
my $failcount = 0; # Count of failed rename attempts.
my $simucount = 0; # Count of simulated file renames.

# Hashes:
my %Modes;
$Modes{P} = 'Prompt';
$Modes{S} = 'Simulate';
$Modes{Y} = 'No-Prompt';
my %Targets;
$Targets{F} = 'Files Only';
$Targets{D} = 'Directories Only';
$Targets{B} = 'Both Files And Directories';
$Targets{A} = 'All Directory Entries';

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   my $t0 = time;
   argv;
   my $pname = get_name_from_path($0);
   say    STDERR '';
   say    STDERR "Now entering program \"$pname\".";
   say    STDERR 'Verbosity is ' . ($Verbose ? 'on' : 'off') . '.';
   say    STDERR 'Recursion is ' . ($Recurse ? 'on' : 'off') . '.';
   say    STDERR 'Target    is ' . $Targets{$Target}         . '.';
   say    STDERR 'Mode      is ' . $Modes{$Mode}             . '.';
   say    STDERR "Regular Expression = $RegExp";
   say    STDERR "Replacement String = $Replace";
   say    STDERR "Modifier Flags     = $Flags";
   say    STDERR "Predicate          = $Predicate";

   $Recurse and RecurseDirs {curdire} or curdire;

   stats;
   say    STDERR '';
   say    STDERR "Now exiting program \"$pname\".";
   printf STDERR "Execution time was %.3f seconds.\n", time - $t0;
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub argv {
   # Get options and arguments:
   my @opts = ();             # options
   my @args = ();             # arguments
   my $end = 0;               # end-of-options flag
   my $s = '[a-zA-Z0-9]';     # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]';  # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
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
      /^-$s*h/ || /^--help$/     and help and exit 777 ;
      /^-$s*e/ || /^--debug$/    and $Db      =  1     ;
      /^-$s*q/ || /^--quiet$/    and $Verbose =  0     ; # DEFAULT
      /^-$s*v/ || /^--verbose$/  and $Verbose =  1     ;
      /^-$s*l/ || /^--local$/    and $Recurse =  0     ; # DEFAULT
      /^-$s*r/ || /^--recurse$/  and $Recurse =  1     ;
      /^-$s*f/ || /^--files$/    and $Target  = 'F'    ;
      /^-$s*d/ || /^--dirs$/     and $Target  = 'D'    ;
      /^-$s*b/ || /^--both$/     and $Target  = 'B'    ; # DEFAULT
      /^-$s*a/ || /^--all$/      and $Target  = 'A'    ;
      /^-$s*p/ || /^--prompt$/   and $Mode    = 'P'    ; # DEFAULT
      /^-$s*s/ || /^--simulate$/ and $Mode    = 'S'    ;
      /^-$s*y/ || /^--noprompt$/ and $Mode    = 'Y'    ;
   }
   if ( $Db ) {
      say STDERR '';
      say STDERR "\$opts = (", join(', ', map {"\"$_\""} @opts), ')';
      say STDERR "\$args = (", join(', ', map {"\"$_\""} @args), ')';
   }

   # Process arguments:
   my $NA = scalar @args;      # Get number of arguments.
   if ( ($NA < 2 || $NA > 4)   # If number of arguments < 2 or > 4
      && !$Db ) {              # and we're not debugging,
      error($NA);              # print error message,
      help;                    # and print help message,
      exit 666;                # and exit, returning The Number Of The Beast.
   }
   if ( $NA >= 1 ) {           # If number of arguments >= 1,
      $RegExp = qr/$args[0]/;  # set $RegExp to $args[0].
   }
   if ( $NA >= 2 ) {           # If number of arguments >= 2,
      $Replace   = $args[1];   # set $Replace to $args[1].
   }
   if ( $NA >= 3 ) {           # If number of arguments >= 3,
      $Flags     = $args[2];   # set $Flags to $args[2].
   }
   if ( $NA >= 4 ) {           # If number of arguments >= 4,
      $Predicate = $args[3];   # set $Predicate to $args[3]
      $Target = 'A';           # and set $Target to 'A' to avoid conflicts with $Predicate.
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

sub curdire {
   ++$dircount;

   # Get and announce current working directory:
   my $curdir = d getcwd;
   if ( $Verbose >= 1 ) {
      say STDOUT "\nDirectory # $dircount: $curdir";
   }

   # Get list of targeted files in current directory:
   my $curdirfiles = GetFiles($curdir, $Target, $RegExp);

   # Process each path that matches $RegExp, $Target, and $Predicate:
   foreach my $file (sort {$a->{Name} cmp $b->{Name}} @$curdirfiles) {
      ++$filecount;
      say STDERR "Debug msg in rnf, in curdire, in foreach: filename = $file->{Name}" if $Db;
      local $_ = e $file->{Path};
      if (eval($Predicate)) {
         ++$predcount;
         curfile($file);
      }
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

sub curfile ($file) {
   # Make variables for old and new names and paths:
   my $OldPath = $file->{Path};
   my $OldName = $file->{Name};
   my $OldDire = get_dir_from_path($OldPath);
   my $NewName = $OldName;
   eval('$NewName' . " =~ s/$RegExp/$Replace/$Flags");
   my $NewPath = path($OldDire, $NewName);

   # Skip to next file if new name is same as old:
   if ($OldName eq $NewName) {
      ++$samecount;
      return 1;
   }
   else {
      ++$diffcount;
   }

   # Announce path and old and new file names:
   say STDOUT '';
   say STDOUT "Old Path = $OldPath";
   say STDOUT "Old Name = $OldName";
   say STDOUT "New Name = $NewName";

   # Take different actions depending on what mode we're in:

   # Prompt Mode:
   if ( 'P' eq $Mode ) {
      say STDOUT 'Rename? (Type y for yes, n for no, q to quit, or a to rename all).';
      GETCHAR: my $c = get_character;
      if ( 'a' eq $c || 'A' eq $c ) {
         $Mode = 'Y';
         if ( rename_file($OldPath, $NewPath) ) {
            ++$renacount;
            say STDOUT "File successfully renamed.";
         }
         else {
            ++$failcount;
            say STDOUT "File rename attempt failed.";
         }
      }
      elsif ( 'y' eq $c || 'Y' eq $c ) {
         if ( rename_file($OldPath, $NewPath) ) {
            ++$renacount;
            say STDOUT "File successfully renamed.";
         }
         else {
            ++$failcount;
            say STDOUT "File rename attempt failed.";
         }
      }
      elsif ( 'n' eq $c || 'N' eq $c ) {
         ++$skipcount;
         say STDOUT "File skipped.";
         return 1;
      }
      elsif ( 'q' eq $c || 'Q' eq $c ) {
         say STDOUT "Quitting application.";
         stats;
         exit 0;
      }
      else {
         say STDOUT 'Invalid keystroke!';
         say STDOUT 'Rename? (Type y for yes, n for no, q to quit, or a to rename all).';
         goto GETCHAR;
      }
   } # end if (current mode is 'P')

   # No-Prompt Mode:
   elsif ( 'Y' eq $Mode ) {
      if ( rename_file($OldPath, $NewPath) ) {
         ++$renacount;
         say STDOUT "File successfully renamed.";
      }
      else {
         ++$failcount;
         say STDOUT "File rename attempt failed.";
      }
   } # end if (current mode is 'Y')

   # Simulation Mode or Debugging:
   elsif ( 'S' eq $Mode || $Db ) {
      ++$simucount;
      say STDOUT "Simulation: Would have renamed file from old name to new name.";
   }

   # Unknown Mode:
   else {
      die "FATAL ERROR in \"rename-files.pl\": unknown mode \"$Mode\".\n$!\n";
   } # end else (unknown mode)

   # Return success code 1 to caller:
   return 1;
} # end sub curfile

sub stats {
   printf STDERR "\n";
   printf STDERR "Processed %5d directories.\n",                                          $dircount;
   printf STDERR "Found     %5d files matching target and regexp.\n",                     $filecount;
   printf STDERR "Found     %5d files also matching predicate.\n",                        $predcount;
   printf STDERR "Bypassed  %5d files because new name was same as old name.\n",          $samecount;
   printf STDERR "Examined  %5d files for which new name was different from old name.\n", $diffcount;
   printf STDERR "Skipped   %5d files at user's request.\n",                              $skipcount;
   printf STDERR "Renamed   %5d files.\n",                                                $renacount;
   printf STDERR "Failed    %5d file rename attempts.\n",                                 $failcount;
   return 1;
} # end sub stats

sub error ($NA) {
   print STDERR ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: You typed $NA arguments, but rename-files.pl takes 2, 3, or 4 arguments.
   END_OF_ERROR
   return 1;
} # end sub error

sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "rename-files.pl", Robbie Hatley's nifty file-renaming Perl script.
   This program renames files and subdirectories in the current working directory
   (and all of its subdirectories if a -r or --recurse option is used)
   by replacing matches to a given regular expression with a given replacement
   string.

   By default, only regular files and subdirectories are processed, but this can
   be altered by using --all|-a (for all entries), --files|-f (for files only),
   or --directories|-d (for directories only).

   -------------------------------------------------------------------------------
   Command lines:

   To print this help and exit:
   rename-files.pl [-h|--help]

   To rename files:
   rename-files.pl [options] Arg1 Arg2 [Arg3] [Arg4]

   -------------------------------------------------------------------------------
   Description of options:

   Option:             Meaning:
   -h or --help        Print help and exit.
   -e or --debug       Print diagnostics.
   -q or --quiet       DON'T print directories.                          (DEFAULT)
   -v or --verbose      DO   print directories.
   -l or --local       Rename files in current directory only.           (DEFAULT)
   -r or --recurse     Recurse subdirectories.
   -f or --files       Rename regular files only.
   -d or --dirs        Rename directories only.
   -b or --both        Rename both regular files and directories.        (DEFAULT)
   -a or --all         Rename ALL directory entries.
   -p or --prompt      Prompt before renaming files.                     (DEFAULT)
   -s or --simulate    Simulate renames (don't actually rename files).
   -y or --noprompt    Rename files without prompting.
         --            End of options (all CL items to right are arguments).

   Multiple single-letter options can be piled-up after a single hyphen.
   For example: "-ldqy" to rename local directories quietly and without prompting.

   If conflicting double-hyphen options are given, later options override earlier.

   If conflicting single-letter options are piled-up after a single hyphen,
   then the order of precedence from highest to lowest will be heyspabdfrlvq.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   WARNING: If the 4th argument ("Predicate"; see below) is used, any target-
   selection options (-f, --files, -d, --directories, -b, --both, -a, --all)
   will be ignored and the target will be set to "all". This is to avoid
   conflict with predicates which may specify a boolean combination of targets.

   -------------------------------------------------------------------------------
   Description of arguments:

   Renamefiles takes 2, 3, or 4 command-line arguments:
   Arg1 (MANDATORY): "Regular Expression" giving pattern to search for.
   Arg2 (MANDATORY): "Replacement String" giving substitution for regex match.
   Arg3 (OPTIONAL ): "Substitution Flags" giving flags for s/// operator.
   Arg4 (OPTIONAL ): "Predicate"          giving file-type boolean predicate.

   Arg1 must be a Perl-Compliant Regular Expression specifying which files
   to rename. To specify multiple patterns, use the | alternation operator.
   To apply pattern modifier letters, use an Extended RegExp Sequence.
   For example, if you want to search for items with names containing "cat",
   "dog", or "horse", title-cased or not, you could use this regexp:
   '(?i:c)at|(?i:d)og|(?i:h)orse'
   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   rename-files, whereas rename-files needs the raw regexp instead.

   Arg2 must be a replacement string giving the string to substitute for each
   RegExp match rename-files finds for Arg1. Arg2 may contain backreferences to
   items stored via (parenthetical groups) in the RegExp in Arg1. For example, if
   Arg1 is '(\d{3})(\d{3})' and Arg2 is '$1-$2', then rename-files would rename
   "123456" to "123-456".

   Arg3 (OPTIONAL), if present, must be flags for the Perl s/// substitution
   operator. For example, if Arg1 is 'dog' and Arg2 is 'cat', normally
   rename-files would rename "dogdog" to "catdog", but if Arg3 is 'g' then the
   result will be "catcat" instead.

   Arg4 (OPTIONAL), if present, must be a boolean predicate using Perl
   file-test operators. The expression must be enclosed in parentheses (else
   rename-files will confuse your file-test operators for options), and then
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

   All arguments should be enclosed in 'single quotes'. Failure to do this may
   cause the shell to decompose an argument to a list of entries in the current
   directory and send THOSE to rename-files, whereas rename-files needs the raw
   arguments.

   Arguments may be freely mixed with options, but arguments are "positional",
   so they MUST appear in the order Arg1, Arg2, Arg3, Arg4. If you mix them up,
   they won't work right.

   If the number of arguments is not an element of the set {2, 3, 4}, this
   program will print an error message and abort execution.

   WARNING: If any of your arguments looks like an option (say, "--help"),
   use a "--" option and put any such arguments to the right of the "--"; that
   will force any items to the right of the "--" to be construed as arguments
   rather than as options (see the fifth usage example below).

   -------------------------------------------------------------------------------
   Verbosity:

   By default, rename-files will NOT announce each directory it navigates,
   and will only print entry stats, info on files to be renamed, and exit stats.

   However, if a "-v" or "--verbose" switch is used, each directory navigated
   will be announced.

   -------------------------------------------------------------------------------
   Directory Navigation:

   By default, rename-files will rename files in the current directory only.
   However, if a "-r" or "--recurse" switch is used, all subdirectories
   of the current directory will also be processed.

   -------------------------------------------------------------------------------
   Targets:

   By default, rename-files renames regular files and subdirectories only.
   This can be altered by using any of the following options:
   -f | --files   => rename files only
   -d | --dirs    => rename directories only
   -b | --both    => rename both files and directories
   -a | --all     => rename ALL directory entries

   HOWEVER, if the 4th argument ("Predicate") is used, all target-selection
   options (-f, --files, -d, --directories, -b, --both, -a, --all) will be
   ignored, and the target will be set to "all". This is to avoid conflict with
   predicates which may specify a boolean combination of targets.

   -------------------------------------------------------------------------------
   Prompting:

   By default, Renamefiles will prompt the user to confirm or reject each rename
   it proposes based on the settings the user gave.  However, this can be altered.

   Using a "-s" or "--simulate" switch will cause Renamefiles to simulate
   file renames rather than actually perform them, displaying the new names which
   would have been used had the rename actually occurred. No files will actually
   be renamed.

   Using a "-y" or "--noprompt" switch will have the opposite effect:
   all renames will be executed automatically without prompting.

   Also, the prompt mode can be changed from "prompt" to "no-prompt" on the fly
   by tapping the 'a' key when prompted.  All remaining renames will then be
   performed automatically without further prompting.

   -------------------------------------------------------------------------------
   Usage Examples:

   rename-files.pl -f 'dog' 'cat'
   (would rename "Dogdog.txt" to "Dogcat.txt")

   rename-files.pl -f '(?i:dog)' 'cat'
   (would rename "Dogdog.txt" to "catdog.txt")

   rename-files.pl -f '(?i:dog)' 'cat' 'g'
   (would rename "Dogdog.txt" to "catcat.txt")

   rename-files.pl -f '--help' 'cat' 'g' '(-p || -S)'
   (would just print this help and exit, because the '--help' would be
   construed as an option, not an argument)

   rename-files.pl -f -- '--help' 'cat' 'g' '(-p || -S)'
   (would rename pipe "bad---help.p" to "bad-cat.p"
   and would rename socket "--help---help.s" to "cat-cat.s",
   because the -- forces '--help' to be an argument, not an option)


   Happy file renaming!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   # Return success code 1 to caller:
   return 1;
} # end sub help
