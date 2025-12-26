#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# file-names-to-sha1.pl
# Converts the names of (nearly) all files in the current directory (and also all subdirectories if a -r or
# --recurse option is used) to the sha1 hashes of the files. (Bypasses '.', '..', '*.ini', '*.db', '*.jbf'.)
# Written by Robbie Hatley.
#
# Edit history:
# Sat Feb 13, 2021: Wrote it.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Thu Oct 03, 2024: Got rid of Sys::Binmode. Got rid of common::sense. Added "use utf8".
# Mon Mar 17, 2025: Now displays both compilation and execution time. Fixed some errors in comments and help.
#                   Changed shebang to "-C63". Changed counters to match my other programs. Still renames
#                   only non-meta regular files, but now uses both regexp and predicate. Increased min ver
#                   from "v5.32" to "v5.36". Got rid of all prototypes. Added signatures.
# Thu Apr 03, 2025: Now using "utf8::all" and "Cwd::utf8". Got rid of "cwd_utf8", "d", "e".
# Tue May 06, 2025: Reverted to "-C63", "utf8", "Cwd", "d", "e", for Cygwin compatibility.
# Fri Dec 26, 2025: Re-reverted to "#!/usr/bin/env perl", "use utf8::all", "use Cwd::utf8".
#                   Moved from "core" to "util". Deleted "core".
##############################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
use RH::Dir;
use RH::Util;

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

# Gibberish file-name pattern:
my $Gib = qr/^[a-z]{8}(?:-\(\d{4}\))?(?:\.[\pL\pN]+)?$/o;

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 1         ; # Be verbose?               bool      Be terse.
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $OriDir    = cwd       ; # Original Directory.       cwd       Current working directory.
# No "$Target" variable because it doesn't make sense to get the SHA1 data hash of a non-data object.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.
my $Yes       = 0         ; # Don't prompt; just do it. bool      Be safe: ask user.

# Counters:
my $direcount = 0; # Count of directories navigated.
my $filecount = 0; # Count of non-meta paths matching target and regexp.
my $predcount = 0; # Count of paths also matching $Predicate.
my $renacount = 0; # Count of files successfully renamed.
my $failcount = 0; # Count of failed file-rename attempts.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
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
      printf STDERR "Now entering program \"%s\" at %02d:%02d:%02d on %d/%d/%d.\n\n",
                    $pname, $s0[2], $s0[1], $s0[0], 1+$s0[4], $s0[3], 1900+$s0[5];
   }

   # Also print compilation time if being verbose:
   if ( $Verbose >= 2 ) {
      printf STDERR "Compilation time was %.3fms\n\n",
                    1000 * ($cmpl_end - $cmpl_beg);
   }

   # Print the values of all variables if debugging or being verbose:
   if ( $Debug >= 1 || $Verbose >= 2 ) {
      print STDERR "pname     = $pname\n",
                   "cmpl_beg  = $cmpl_beg\n",
                   "cmpl_end  = $cmpl_end\n",
                   "Options   = (@Opts)\n",
                   "Arguments = (@Args)\n",
                   "Debug     = $Debug\n",
                   "Help      = $Help\n",
                   "Verbose   = $Verbose\n",
                   "Recurse   = $Recurse\n",
                   "RegExp    = $RegExp\n",
                   "Predicate = $Predicate\n",
                   "OriDir    = $OriDir\n\n";
   }

   # If user wants help, print help:
   if ( $Help ) {
      help
   }

   # Else if in yesman mode, "just do it":
   elsif ( $Yes ) {
      $Recurse and RecurseDirs {curdire} or curdire;
      stats;
   }

   # Otherwise, print warning, prompt user, and if user agrees, change file names to SHA1:
   else {
      warn
      "WARNING!!! THIS PROGRAM CONVERTS THE NAMES OF (NEARLY) ALL FILES IN THE\n".
      "CURRENT DIRECTORY (AND ALSO ALL SUBDIRECTORIES IF A -r OR --recurse OPTION\n".
      "IS USED) TO THE SHA1 HASHES OF THE FILES. (BYPASSES '.', '..', '*.ini',\n".
      "'*.db', AND '*.jbf' FILES.) ALL EXISTING FILE NAMES WILL BE OBLITERATED!!!\n".
      "ARE YOU SURE THIS IS REALLY WHAT YOU WANT TO DO???\n".
      "PRESS 'G' (shift-g) TO CONTINUE, OR ANY OTHER KEY TO ABORT.\n";
      my $char = get_character;
      if ($char eq 'G') {
         $Recurse and RecurseDirs {curdire} or curdire;
         stats;
      }
   }

   # Stop execution timer:
   my $t1 = time;
   my @s1 = localtime($t1);

   # Print exit message if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      my $te = $t1 - $t0; my $ms = 1000 * $te;
      printf STDERR
         "\nNow exiting program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n"
        ."Execution time was %.3fms.",
        $s1[2], $s1[1], $s1[0], 1+$s1[4], $s1[3], 1900+$s1[5], $ms;
   }

   # Exit program, returning success code "0" to caller:
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
      /^--$/ && !$end        # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1           # so if we see that, then set the "end-of-options" flag
      and push @Opts, $_     # and push the "--" to @Opts
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we get a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @Opts, $_     # then push item to @Opts
      or  push @Args, $_;    # else push item to @Args.
   }

   # Process options:
   for ( @Opts ) {
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
      /^-$s*e/ || /^--debug$/   and $Debug   =  1  ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0  ;
      /^-$s*t/ || /^--terse$/   and $Verbose =  1  ; # Default.
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2  ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0  ; # Default.
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1  ;
      /^-$s*y/ || /^--yes$/     and $Yes     =  1  ; # DANGER: BE SURE YOU KNOW WHAT YOU'RE DOING!
   }

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If user typed more than 2 arguments, and we're not debugging, print error and help messages and exit:
   if ( $NA > 2                  # If number of arguments > 2
        && !$Debug && !$Help ) { # and we're not debugging and not getting help,
      error($NA);                # print error message,
      help;                      # and print help message,
      exit 666;                  # and exit, returning The Number Of The Beast.
   }

   # First argument, if present, is a file-selection regexp:
   if ( $NA > 0 ) {              # If number of arguments > 0,
      $RegExp = qr/$Args[0]/o;   # set $RegExp to $Args[0].
   }

   # Second argument, if present, is a file-selection predicate:
   if ( $NA > 1 ) {              # If number of arguments >= 2,
      $Predicate = $Args[1];     # set $Predicate to $Args[1].
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   ++$direcount;
   my $cwd = cwd;
   say STDOUT "\nDir # $direcount: $cwd\n";
   my @paths = sort {$a cmp $b} glob_regexp_utf8($cwd, 'F', $RegExp, $Predicate);
   foreach my $path (@paths) {
      # Bypass all non-data files (dirs, links, pipes, sockets, etc):
      next if !is_data_file($path);
      # Bypass all meta files (hidden, settings, metadata, etc):
      next if is_meta_file($path);
      # If we get to here, send path to curfile():
      curfile($path);
   }
   return 1;
} # end sub curdire

# Process current file.
sub curfile ($path) {
   ++$filecount;
   my $oldname = get_name_from_path($path);
   my $newname = hash($path, 'sha1', 'name');
   if ( '***ERROR***' eq $newname ) {
      say "Couldn't find available SHA1 name for $path";
      return 0;
   }
   rename_file($oldname, $newname)
   and ++$renacount
   and say "Renamed \"$oldname\" to \"$newname\"."
   and return 1
   or  ++$failcount
   and warn "Failed to rename \"$oldname\" to \"$newname\".\n"
   and return 0;
} # end sub curfile

# Print stats:
sub stats {
   if ( $Verbose >= 1 ) {
      print STDERR ((<<"      END_OF_STATS") =~ s/^      //gmr);

      Stats for running "$pname" in directory tree "$OriDir":
      Navigated $direcount directories.
      Found $filecount data files matching regexp "$RegExp" and predicate "$Predicate".
      Renamed $renacount files and failed $failcount file-rename attempts.
      END_OF_STATS
   }
   return 1;
} # end sub stats

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "file-names-to-sha1.pl". This program renames all non-meta data
   files in the current directory (and all subdirectories if a -r or --recurse
   option is used) to names consisting of the SHA-1 hash of the data in the file
   followed by the file's original name extension. This can be useful for
   unidentified image files which you want to identify via Internet databases of
   SHA-1 hashes of files.

   -------------------------------------------------------------------------------
   WARNING: THIS PROGRAM CONVERTS THE NAMES OF (NEARLY) ALL REGULAR FILES IN THE
   CURRENT DIRECTORY (AND ALSO ALL SUBDIRECTORIES IF A -r or --recurse OPTION
   IS USED) TO THE SHA1 HASHES OF THE FILES. IT OBLITERATES EXISTING FILE NAMES!
   ONLY USE THIS PROGRAM IF THAT'S WHAT YOU REALLY WANT TO DO!

   -------------------------------------------------------------------------------
   Command lines:

   file-names-to-sha1.pl --help | -h             (to print this help and exit)
   file-names-to-sha1.pl [options] [arguments]   (to give SHA1 names to files)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics.
   -q or --quiet      Be quiet.                         (DEFAULT)
   -t or --terse      Be terse.
   -v or --verbose    Be verbose.
   -l or --local      DON'T recurse subdirectories.     (DEFAULT)
   -r or --recurse    DO    recurse subdirectories.
   -y or --yes        Don't prompt; just do it. (DANGEROUS!!!)
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively process items.

   If two piled-together single-letter options conflict, the option
   appearing lowest on the options chart above will prevail.
   If two separate (not piled-together) options conflict, the right
   overrides the left.

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

   A number of arguments greater than 2 will cause this program to print an error
   message and abort.


   Happy file renaming!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
