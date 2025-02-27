#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# delete-young-files.pl
# Deletes all regular files in the current directory (and all subdirectories if a -r or --recurse option is
# used) which were modified less than a given time (in days) ago (default is 365.2422 days).
#
# This program skips all directory entries with names "." or ".." or suffixes "*.db", "*.ini", and "*.jbf",
# all names which don't point to something that exists, and all files which are directories or link or aren't
# regular files. If any regexps are given, this program also skips all files with names that don't match at
# least one of those regexps.
#
# Edit history:
# Thu Aug 15, 2024: Wrote it, based heavily on existing program "delete-old-files.pl".
# Wed Feb 26, 2025: Trimmed horizontal dividers. Got rid of all prototypes and empty signatures.
##############################################################################################################

use v5.36;
use utf8;
use Cwd 'getcwd';
use POSIX 'floor', 'ceil';
use Time::HiRes 'time';
use RH::Util;
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
sub error   ; # Print error message.
sub help    ; # Print help  message.

# ======= VARIABLES: =========================================================================================

# Settings:                   Meaning:                         Range:    Default:
my $Recurse  = 0          ; # Recurse subdirectories?          bool      0 (don't recurse)
my $Simulate = 0          ; # Simulate and print diagnostics?  bool      0 (don't simulate)
my $RegExp   = qr/^.+$/o  ; # Regular Expression.              regexp    qr/^.+$/o (matches all strings)
my $Yes      = 0          ; # Proceed without prompting?       bool      prompt
my $Limit    = 365.2422   ; # Minimum age in days.             float     365.2422 days

# Counters:
my $direcount = 0; # Count of directories processed.
my $filecount = 0; # Count of files processed.
my $skipcount = 0; # Count of files skipped.
my $simucount = 0; # Count of file deletion simulations.
my $attecount = 0; # Count of file deletion attempts.
my $delecount = 0; # Count of file deletion successes.
my $failcount = 0; # Count of file deletion failures.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   my $t0 = time;
   argv;
   say "\nNow entering program \"" . get_name_from_path($0) . "\".";
   say "Simulate = $Simulate";
   say "Recurse  = $Recurse";
   say "RegExp   = $RegExp";
   say "Yes      = $Yes";
   say "Limit    = $Limit";

   unless ($Yes || $Simulate) {
                   say '';
                   say 'WARNING: THIS PROGRAM WILL DELETE ALL TARGETED FILES';
      $Recurse and say 'IN THE CURRENT DIRECTORY AND IN ALL OF ITS SUBDIRECTORIES'
               or  say 'IN THE CURRENT DIRECTORY';
                   say "WHICH WERE MODIFIED LESS THAN $Limit DAYS AGO.";
                   say 'ARE YOU SURE THAT THIS IS WHAT YOU REALLY WANT TO DO???';
                   say 'PRESS "&" (SHIFT-7) TO CONTINUE OR ANY OTHER KEY TO ABORT.';
      my $char = get_character;
      exit 0 unless '&' eq $char;
   }

   $Recurse and RecurseDirs {curdire} or curdire;

   # Print stats:
   stats;

   # We be done, so scram:
   my $t1 = time; my $te = $t1 - $t0;
   say "\nNow exiting program \"" . get_name_from_path($0) . "\". Execution time was $te seconds.";
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV :
sub argv {
   # Get options and arguments:
   my @opts = ();            # options
   my @args = ();            # arguments
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV,
      /^--$/                 # "--" = end-of-options marker = construe all further CL items as arguments,
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
      /^-$s*h/ || /^--help$/     and help and exit 777 ;
      /^-$s*s/ || /^--simulate$/ and $Simulate =  1    ;
      /^-$s*l/ || /^--local$/    and $Recurse  =  0    ;
      /^-$s*r/ || /^--recurse$/  and $Recurse  =  1    ;
      /^-$s*y/ || /^--yes$/      and $Yes      =  1    ;
      /^--age=(\d+\.?\d*)$/      and $Limit    =  $1   ;
   }

   # If emulating, print options and arguments:
   if ( $Simulate ) {
      say STDERR '';
      say STDERR "\@opts = (", join(', ', map {"\"$_\""} @opts), ')';
      say STDERR "\@args = (", join(', ', map {"\"$_\""} @args), ')';
   }

   # Process arguments:
   my $NA = scalar(@args);
   if    (0 == $NA) {                                 ; } # Do nothing.
   elsif (1 == $NA) {$RegExp = qr/$args[0]/o          ; } # Set $RegExp.
   else             {error($NA) and help and exit 666 ; } # Print error and help messages then exit 666.
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Increment directory counter:
   ++$direcount;

   # Get and announce current working directory:
   my $cwd = d(getcwd());
   say "\nDirectory # $direcount: $cwd\n";

   # Get list of file-info packets in $cwd matching target ('F', regular files only) and $RegExp:
   my $curdirfiles = GetFiles($cwd, 'F', $RegExp);

   # Iterate through $curdirfiles and send each file to curfile():
   foreach my $file (@{$curdirfiles}) {
      curfile($file);
   }
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($file) {
   # Increment file counter:
   ++$filecount;

   # Get path, name, suffix, and age:
   my $path   = $file->{Path};
   my $name   = $file->{Name};
   my $suffix = get_suffix($name);
   my $age    = time() - $file->{Mtime};

   # Skip this file if it is hidden (has a name starting with "."):
   if ('.' eq substr $name, 0, 1) {
      ++$skipcount;
      return 1;
   }

   # Skip this file if it is "meta" (suffix is '.ini', '.db', or '.jbf'):
   if ('.ini' eq $suffix || '.db' eq $suffix || '.jbf' eq $suffix) {
      ++$skipcount;
      return 1;
   }

   # Get min age in seconds. ("$Limit" is in days, defaulting to 365.2422 days, so we need to convert.
   # Seconds-per-day = 86400.)
   my $min_seconds = $Limit * 86400;

   # Skip this file if its age is greater-than-or-equal-to our age limit:
   if ($age >= $min_seconds) {
      ++$skipcount;
      return 1;
   }

   # If just simulating, print the name of the file we would have deleted and return 1:
   if ($Simulate) {
      ++$simucount;
      say "Would have deleted \"$name\".";
      return 1;
   }

   # Attempt to unlink_utf8 $name:
   ++$attecount;
   unlink(e($name))
   and ++$delecount
   and print STDOUT "Deleted \"$name\".\n"
   and return 1
   or ++$failcount
   and print STDERR "Failed to delete \"$name\".\n$!\n"
   and return 0;
} # end sub curfile

sub stats {
   print STDOUT "\nStatistics for program \"delete-young-files.pl\":\n";
   if ($Simulate)
   {
      print STDOUT
      "Note: This program was run in simulation mode,\n",
      "so no deletions were actually performed.\n",
      "Navigated $direcount directories.\n",
      "Skipped $skipcount hidden, meta, and elder files.\n",
      "Simulated $simucount young-file deletions.\n",
   }
   else
   {
      print STDOUT
      "Navigated $direcount directories.\n",
      "Skipped $skipcount hidden, meta, and elder files.\n",
      "Attempted to delete $attecount young files.\n",
      "Successfully deleted $delecount young files.\n",
      "Failed $failcount file deletion attempts.\n";
   }
   return 1;
} # end sub stats

sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);
   Error: you typed $NA arguments, but this program takes at most 1 argument,
   which, if present, must be a Perl-Compliant Regular Expression specifying
   which directory entries to process. Help follows:

   END_OF_ERROR
   return 1;
} # end sub error

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Intro:
   Welcome to "delete-young-files.pl", Robbie Hatley's young-file-deletion program.
   Deletes all files in the current directory (and all subdirectories, if a -r or
   --recurse option is used) which were modified less than a given time ago in
   days. (The default age limit is 365.2422 days.)

   This program skips all nonexistent, hidden, meta (suffixes ".db", ".ini",
   ".jbf"), and non-regular files.

   If a regular expression is given as this program's sole argument, this program
   also skips all files which don't match that regular expression.

   This program should not be run frivolously, because it can permanently delete
   a large number of files all at once. Hence it prompts the user "ARE YOU SURE
   THAT THAT IS WHAT YOU ACTUALLY WANT TO DO???" unless in simulation or no-prompt
   mode.

   Command line:
   delete-young-files.pl [options] [arguments]

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Description of options:
   Option:                  Meaning:
   "-h" or "--help"         Print this help and exit.
   "-s" or "--simulate"     Merely simulate renames.
   "-l" or "--local"        DON'T recurse subdirectories. (default)
   "-r" or "--recurse"      DO recurse subdirectories.
   "-y" or "--yes"          Delete all old files without prompting.
   "--age=###"              Set max age (where "###" is any positive real number)
   Defaults are: no help, no simulate, no recurse, no yes, age = "365.2422 days".
   Multiple single-letter options may be piled after a single hyphen. Eg, "-yr".
   All other options are ignored.

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Description of arguments:
   In addition to options, this program can take one optional argument which, if
   present, must be a Perl-Compliant Regular Expression specifying which items to
   process. To specify multiple patterns, use the | alternation operator.
   To apply pattern modifier letters, use an Extended RegExp Sequence.
   For example, if you want to search for items with names containing "cat",
   "dog", or "horse", title-cased or not, you could use this regexp:
   '(?i:c)at|(?i:d)og|(?i:h)orse'

   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   If the number of arguments is not 0 or 1, this program will print error
   and help messages and exit.

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Example program invocation:
   To delete all files with "cat", "dog", or "horse" (title-cased or not) in
   their names, in any subdirectory, which are younger than 275 days, type this:
   delete-young-files.pl -ry --age=275 '(?i:c)at|(?i:d)og|(?i:h)orse'

   Happy young-file deleting!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
