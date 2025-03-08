#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# fix-spacey-directory-names.pl
# Converts spaces (and other troublesome characters) in directory names to BASH-safe characters.
# Processes subdirectories of current working directory (infinite levels deep if recursing, or just 1 level
# deep if NOT recursing). Does NOT attempt to rename current working directory itself, as that would cause
# errors in BASH.
# Written by Robbie Hatley.
# Edit history:
# Sat Mar 18, 2023: Wrote it.
# Thu Aug 15, 2024: -C63; got rid of unnecessary "use" statements.
# Fri Mar 07, 2025: Trimmed dividers and wrapped over-length lines to 110. Changed from using "GetFiles" to
#                   using "glob_regexp_utf8" (faster, as we only need paths, not other info). Fixed bug which
#                   attempted to rename current working directory (causes errors in BASH). Now sending all
#                   error, help, stats, and debug messages to STDERR; only renaming messages go to STDOUT.
##############################################################################################################

use v5.36;
use utf8;
use Time::HiRes 'time';
use Cwd 'getcwd';
use RH::Dir;
use RH::Util;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub cursubd ; # Process current subdirectory
sub stats   ; # Print statistics.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

# ======= VARIABLES: =========================================================================================

# Settings:                    Meaning:                    Range:    Default:
   $"         = ', '      ; # Quoted-array formatting.  string    Comma space.
my $pname     = ''        ; # Name of program.          string    Empty.
my @opts      = ()        ; # options                   array     Options.
my @args      = ()        ; # arguments                 array     Arguments.
my $Db        = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 0         ; # Be verbose?               bool      Shhhh!! Be quiet!!
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.

# Counters:
my $direcount = 0         ; # Count of directories processed by curdire().
my $renacount = 0         ; # Count of directories renamed   by curfile().
my $failcount = 0         ; # Count of failed directory rename attempts.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Start timer:
   my $t0 = time;

   # Process @ARGV and set settings:
   argv;

   # Get program name:
   $pname = substr $0, 1 + rindex $0, '/';

   # Print entry message if being verbose:
   if ($Verbose) {
      print STDERR "\nNow entering program \"$pname\".\n".
                   "RegExp  = $RegExp\n".
                   "Recurse = $Recurse\n".
                   "Verbose = $Verbose\n";
   }

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   $Help and help or ($Recurse and RecurseDirs {curdire} or curdire) and stats;


   # NOTE: Do NOT attempt to rename current working directory!!!
   # NO!!! curfile(d getcwd); NO!!!
   # That will cause errors in BASH. Just rename it manually if needed.

   # Stop timer:
   my $t1 = time; my $te = $t1 - $t0; my $ms = 1000.0 * $te;

   # Print exit message if being verbose:
   if ($Verbose) {say "\nNow exiting program \"$pname\". Execution time was ${ms}ms."}

   # We're finished, so exit program and return success code 0 to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV :
sub argv {
   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV,
      /^--$/                 # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1           # so if we see that, then set the "end-of-options" flag
      and push @opts, $_     # and push the "--" to @opts
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we get a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @opts, $_     # then push item to @opts
      or  push @args, $_;    # else push item to @args.
   }

   # Process options:
   for ( @opts ) {
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
      /^-$s*e/ || /^--debug$/   and $Db      =  1  ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0  ; # Default.
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2  ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0  ; # Default.
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1  ;
   }

   # Get number of arguments:
   my $NA = scalar(@args);
   if    ( 0 == $NA ) {                                  } # Do nothing.
   elsif ( 1 == $NA ) {$RegExp = qr/$args[0]/o           } # Set $RegExp.
   else               {error($NA); say ''; help; exit 666} # Print error and help messages then exit 666.
   return 1;
} # end sub argv

# Process current directory:
sub curdire
{
   # Get list of subdirectory-info packets in cwd matching $RegExp:
   my $cwd = d getcwd;
   my @subdirs = glob_regexp_utf8($cwd, 'D', $RegExp);

   # Iterate through @subdirs and send each file to curfile():
   foreach my $subdir (@subdirs) {
      cursubd($cwd, $subdir);
   }
   return 1;
} # end sub curdire

# Process current file:
sub cursubd ($cwd, $oldpath) {
   # Increment file counter:
   ++$direcount;

   # Announce current subdirectory if being verbose:
   say "\nDirectory # $direcount: \"$oldpath\"." if $Verbose;

   # Get oldname and make newname:
   my $oldname = get_name_from_path($oldpath);
   my $newname = $oldname;

   # Clean garbage from newname:
   $newname =~ s/\`/‘/g;
   $newname =~ s/\'/’/g;
   $newname =~ s/\s+-+|-+\s+|\s+-+\s+/_/g;
   $newname =~ s/\s*,\s*/_/g;
   $newname =~ s/\s*\.\s*/_/g;
   $newname =~ s/\s*&\s*/-and-/g;
   $newname =~ s/^\s*\(\s*//;
   $newname =~ s/\s*\(\s*/_/g;
   $newname =~ s/\s*\)\s*$//;
   $newname =~ s/\s*\)\s*/_/g;
   $newname =~ s/^\s*\[\s*//;
   $newname =~ s/\s*\[\s*/_/g;
   $newname =~ s/\s*\]\s*$//;
   $newname =~ s/\s*\]\s*/_/g;
   $newname =~ s/\s+/-/g;
   $newname =~ s/_{2,}/_/g;

   # If newname is different from oldname, rename this subdirectory:
   if ($newname ne $oldname) {
      # If debugging, just emulate:
      if ($Db) {
         say "Emulated rename: \"$oldname\" => \"$newname\"";
      }
      else {
         say "Renaming \"$oldname\" => \"$newname\"";
         my $newpath = path($cwd,$newname);
         rename_file($oldpath,$newpath) and ++$renacount
         or ++$failcount and say "Rename failed.\n$!";
      }
   }

   # We're done, so scram:
   return 1;
} # end sub curfile

# Print statistics for this program run:
sub stats {
   if ($Verbose) {
      print STDERR "\nStatistics for \"fix-spacey-directory-names.pl\":\n".
                   "Examined $direcount directory names.\n".
                   "Renamed  $renacount troublesome directory names.\n".
                   "Failed   $failcount renamed attempts.\n";
   }
   return 1;
} # end sub stats

# Handle errors:
sub error ($err_msg)
{
   print STDERR ((<<"   END_OF_ERROR") =~ s/^   //gmr);
   Error: you typed $err_msg arguments, but this program takes at most 1 argument,
   which, if present, must be a Perl-Compliant Regular Expression specifying
   which directories to process.
   END_OF_ERROR
} # end sub error

# Print help:
sub help
{
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "fix-spacey-directory-names.pl". This program converts spaces and
   other BASH-unfriendly characters in the name of the subdirectories of the
   current working directory (infinite levels deep if a "-r" or "--recurse" option
   is used, otherwise just 1 level deep) to BASH-safe characters, so that directory
   names do not require quoting when used in BASH commands. NOTE: this program does
   NOT attempt to rename the current working directory itself, as that would cause
   errors in BASH. Rename it manually if needed, after "cd ..".

   Command lines:
   program-name.pl -h | --help            (to print this help and exit)
   program-name.pl [options] [arguments]  (to clean-up directory names)

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.
   "-q" or "--quiet"            Don't be verbose.
   "-v" or "--verbose"          Do    be Verbose.    (DEFAULT)
   "-l" or "--local"            Don't recurse.
   "-r" or "--recurse"          Do    recurse.       (DEFAULT)

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

   Happy directory name cleaning!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
