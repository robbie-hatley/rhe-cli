#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# canonicalize-permissions.pl
# Canonicalizes permissions of directory entries, except for hidden files & directories.
#
# Written by Robbie Hatley, beginning on Sunday March 5, 2023.
#
# Edit history:
# Sun Mar 05, 2023: Wrote stub. (NOT YET FUNCTIONAL.)
# Thu Aug 04, 2023: Reduced width from 120 to 100. Got rid of all prototypes (using signatures instead).
#                   Got rid of cwd_utf8 (using "d getcwd" instead). Got rid of file-type counters.
#                   Got rid of "--debug=no", "--local", "--quiet" (already defaults).
#                   Changed "--debug=yes" to just "--debug". Now using "my $pname = get_name_from_path($0);".
#                   Elapsed time is now in milliseconds.
# Wed Aug 09, 2023: Dramatically symplified permission-setting. Created new subs "set_nav", "set_exe", and
#                   "set_nox". Added several new suffixes. Now handles makefiles (noex).
# Fri Aug 25, 2023: Added "quiet" and "verbose" options to control output. Added "nodebug" option.
#                   Fixed bug in which all image files were having their perms set TWICE.
#                   Added stipulation that this program does not process hidden files.
# Wed Aug 30, 2023: Entry & Exit messages are now controlled by $Verbose only, not $Debug.
# Thu Aug 31, 2023: Clarified sub argv().
#                   Got rid of "/...|.../" in favor of "/.../ || /.../" (speeds-up program).
#                   Simplified way in which options and arguments are printed if debugging.
#                   Removed "$" = ', '" and "$, = ', '". Got rid of "/o" from all instances of qr().
#                   Changed all "$db" to $Debug". Debugging now simulates renames instead of exiting in main.
#                   Removed "no debug" option as that's already default in all of my programs.
#                   Variable "$Verbose" now means "print per-file info", and default is to NOT do that.
#                   STDERR = "stats and serious errors". STDOUT = "file permissions set, and dirs if verbose".
# Wed Sep 06, 2023: Predicate now overrides target and forces it to 'A' to avoid conflicts with predicate.
# Wed Aug 14, 2024: Removed unnecessary "use" statements.
# Tue Mar 04, 2025: Shebang is now "#!/usr/bin/env -S perl -C63". Nixed "__END__" marker.
# Thu May 01, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e".
# Tue May 06, 2025: Reverted to "-C63", "utf8", "Cwd", "d", "e", for Cygwin compatibility.
# Fri Dec 26, 2025: Re-reverted to "#!/usr/bin/env perl", "use utf8::all", "use Cwd::utf8".
#                   Moved from "core" to "util". Deleted "core".
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

# Settings:     Default:       Meaning of setting:           Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 0         ; # Be verbose?               0,1,2     Shhh! Be quiet!
my $OriDir    = cwd       ; # Original directory.       cwd       Directory on program entry.
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $Target    = 'A'       ; # Target                    F|D|B|A   Target all directory entries.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.
my $Hidden    = 0         ; # Process hidden items?     bool      Don't process hidden items.

# Counters:
my $direcount = 0         ; # Count of directories processed by curdire().
my $filecount = 0         ; # Count of files matching target, regexp, and predicate.
my $hiskcount = 0         ; # Count of all hidden  files skipped.
my $opencount = 0         ; # Count of all regular files we could    open.
my $noopcount = 0         ; # Count of all regular files we couldn't open.
my $readcount = 0         ; # Count of all regular files we could    read.
my $nordcount = 0         ; # Count of all regular files we couldn't read.
my $permcount = 0         ; # Count of all permissions set.
my $simucount = 0         ; # Count of all simulated setting of permissions.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub set     ; # Set the permissions of a directory or file.
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
      say STDERR "Settings:";
      say STDERR "OriDir    = $OriDir";
      say STDERR "Recurse   = $Recurse";
      say STDERR "Target    = $Target";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR '';
   }

   # If debugging, print the values of all variables except counters, after processing @ARGV:
   if ( $Debug >= 1 ) {
      say STDERR 'Debug: Values of all variables after processing @ARGV:';
      say STDERR "pname     = $pname";
      say STDERR "cmpl_beg  = $cmpl_beg";
      say STDERR "cmpl_end  = $cmpl_end";
      say STDERR "Options   = (@Opts)";
      say STDERR "Arguments = (@Args)";
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR "Verbose   = $Verbose";
      say STDERR "OriDir    = $OriDir";
      say STDERR "Recurse   = $Recurse";
      say STDERR "Target    = $Target";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR "Hidden    = $Hidden";
      say STDERR '';
   }

   # If user requested help, just print help:
   if ($Help) {help}
   # Otherwise, canonicalize permissions:
   else {
      # Count max levels of recursion:
      my $mlor = 0;
      # If recursing, run curdire() on every directory in this tree:
      if ($Recurse) {$mlor = RecurseDirs {curdire}}
      # Otherwise, run curdire() on current directory only:
      else {curdire}
      # If we've been printing $direcount repeatedly on top of itself, print closing newline:
      if ($Verbose < 1) {print STDOUT "\n"}
      # If we recursed, print max levels of recursion:
      if ($Recurse) {say STDOUT "\nMaximum levels of recursion reached = $mlor"}
      # Print stats:
      stats
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

# Process @ARGV :
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
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
      /^-$s*e/ || /^--debug$/   and $Debug   =  1  ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0  ; # Default.
      /^-$s*t/ || /^--terse$/   and $Verbose =  1  ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2  ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0  ; # Default.
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1  ;
      /^-$s*f/ || /^--files$/   and $Target  = 'F' ;
      /^-$s*d/ || /^--dirs$/    and $Target  = 'D' ;
      /^-$s*b/ || /^--both$/    and $Target  = 'B' ;
      /^-$s*a/ || /^--all$/     and $Target  = 'A' ; # Default.
      /^-$s*n/ || /^--hidden$/  and $Hidden  =  1  ;
   }

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If user typed more than 2 arguments, and we're not debugging or getting help,
   # then print error and help messages and exit:
   if ( $NA >= 3 && !$Debug ) {  # If number of arguments >= 3 and we're not debugging,
      error($NA);                # print error message,
      help;                      # and print help message,
      exit 666;                  # and exit, returning The Number Of The Beast.
   }

   # First argument, if present, is a file-selection regexp:
   if ( $NA >= 1 ) {             # If number of arguments >= 1,
      $RegExp = qr/$Args[0]/o;   # set $RegExp to $args[0].
   }

   # Second argument, if present, is a file-selection predicate:
   if ( $NA >= 2 ) {             # If number of arguments >= 2,
      $Predicate = $Args[1];     # set $Predicate to $args[1].
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Increment "directories navigated" counter:
   ++$direcount;

   # Get current working directory:
   my $cwd = cwd;

   # Announce each current working directory separately if being terse or verbose:
   if ( $Verbose >= 1 ) {
      say STDOUT "\nDirectory # $direcount: $cwd\n";
   }

   # Otherwise, just write "Directory # " once, then write the numbers on top of each other:
   else {
      if ( 1 == $direcount ) {
         printf STDOUT "\nDirectory # %6d", $direcount;
      }
      else {
         printf STDOUT "\b\b\b\b\b\b%6d", $direcount;
      }
   }

   # Get list of file-info packets in $cwd matching $Target, $RegExp, and $Predicate:
   my $curdirfiles = GetFiles($cwd, $Target, $RegExp, $Predicate);
   my $nf = scalar(@$curdirfiles);
   BLAT "Debug msg in canoperm, in curdire; just got $nf file records.";

   # Send each file that matches $RegExp, $Target, and $Predicate to curfile()
   # (unless the file is hidden and we're not processing hidden files):
   foreach my $file (@$curdirfiles) {
      BLAT "Debug msg in canoperm, in curdire, in foreach; curr file = \"$file->{Name}\".";
      # Don't process hidden items unless user requests that:
      if ( '.' eq substr($file->{Name}, 0, 1) && ! $Hidden ) {
         ++$hiskcount; # Increment "hidden skip" counter.
         next;
      }
      # Send item to curfile():
      curfile($file);
   }
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($file) {
   # Increment "files processed" counter:
   ++$filecount;

   # If this is a directory, set it to "navigable":
   if ( 'D' eq $file->{Type} ) {
      set($file, 0775);
   }

   # Else if this is a regular file, those are mixed bags:
   elsif ( 'F' eq $file->{Type} ) {
      # Make variables for raw and lower-case-dotless suffix:
      my ($suff, $lsuf);

      # Get existing suffix:
      $suff = get_suffix($file->{Name});

      # Get lower-case dot-less version of suffix:
      $lsuf = lc $suff =~ s/^\.//r;

      # If $lsuf is NOT blank:
      if ( length($lsuf) > 0 ) {
         BLAT "Debug msg in canoperm, in curfile: file $file->{Name} has suffix \"$lsuf\".";
         switch ($lsuf) {
            # Scripts in known languages need to be executable:
            # NOTE RH 2024-09-06: I removed "au3", "bat", "ps1", "vbs" because from the standpoint of Linux,
            # such files should NOT be considered "executable" because they're DOS/Windows, not Linux.
            # I also added "elf" and "run" as these ARE executable Linux files.
            case /^(apl|awk|elf|pl|perl|py|raku|run|sed|sh)$/ {
               BLAT "Debug msg in canoperm, in curfile: setting file $file->{Name} to \"executable\".";
               set($file, 0775);
            }

            # Files with any other non-blank suffixes do NOT need to be executable:
            else {
               BLAT "Debug msg in canoperm, in curfile: setting file $file->{Name} to \"NOT executable\".";
               set($file, 0664);
            }
         }
      }

      # Else if $lsuf is blank, try to open the file and grab its first 4 bytes:
      else {
         BLAT "Debug msg in canoperm, in curfile: file $file->{Name} has no suffix.";
         my $buffer = ''    ;
         my $fh     = undef ;
         my $bytes  = 0     ;
         if ( open($fh, '< :raw', $file->{Path} ) ) {
            BLAT"Debug msg in canoperm, in curfile: Opened file \"$file->{Name}\".";
            ++$opencount;
            if ( read($fh, $buffer, 4) ) {
               $bytes = length($buffer);
               BLAT "Debug msg in canoperm, in curfile: Read file \"$file->{Name}\".";
            }
            else {
               BLAT"Debug msg in canoperm, in curfile: Couldn't read file \"$file->{Name}\".";
            }
            close($fh);
         }
         else {
            BLAT"Debug msg in canoperm, in curfile: Couldn't open file \"$file->{Name}\".";
            ++$noopcount;
         }

         # If we managed to read 4-or-more bytes of data from the file, make a decision based on that:
         if ( 4 == $bytes ) {
            BLAT"Debug msg in canoperm, in curfile: Got 4 bytes from file \"$file->{Name}\".";
            ++$readcount;
            if ( '#!' eq substr($buffer, 0, 2) ) {             # Hashbang script.
               BLAT "Debug msg in canoperm, in curfile: File $file->{Name} is a hashbang script";
               set($file, 0775);                               # Set it to "executable".
            }
            elsif ( "\x{7F}ELF" eq substr($buffer, 0, 4) ) {   # Linux ELF "executable".
               BLAT "Debug msg in canoperm, in curfile: File $file->{Name} is an ELF executable";
               set($file, 0775);                               # Set it to "executable".
            }
            else {                                             # Data file.
               BLAT "Debug msg in canoperm, in curfile: File $file->{Name} is a data file";
               set($file, 0664);                               # Set it to "NOT executable".
            }
         }

         # Else if we did NOT manage to read 4-or-more bytes of data from the file, do nothing:
         else {
            ++$nordcount;
            BLAT "Debug msg in canoperm, in curfile: Couldn't get 4 bytes from file $file->{Name}";
            ; # Do nothing.
         }
      } # end else ($lsuf is blank)
   } # end if (regular file)

   # For things OTHER THAN regular files and directories, do nothing:
   else {
      BLAT "Debug msg in canoperm, in curfile: file \"$file->{Name}\" is one of the weird ones.";
      ; # Do nothing.
   } # end else (neither dir nor file)

   # Return success code 1 to caller:
   return 1;
} # end sub curfile ($file)

# Set permissions on a file, or simulate doing so:
sub set ($file, $perm) {
   # Get a description of the file:
   my $descr;
   switch ($file->{Type}) {
      case 'F' {$descr = "file"}
      case 'D' {$descr = "directory"}
      else     {$descr = "item"}
   }
   # Get a description of the permissions:
   my $perms;
   switch ($perm) {
      case 0775 {$perms = ("directory" eq $descr) ?     "navigable" :     "executable"}
      case 0664 {$perms = ("directory" eq $descr) ? "NOT-navigable" : "NOT-executable"}
      else      {$perms = "unknown"}
   }
   # If debugging, just simulate:
   if ( $Debug ) {
      ++$simucount;
      say "Simulation: would have set $descr \"$file->{Name}\" to $perms.";
   }
   # Else if NOT debugging, change permissions:
   else {
      ++$permcount;
      chmod $perm, $file->{Path};
      if ( $Verbose ) {
         say "Set $descr \"$file->{Name}\" to $perms.";
      }
   }
   # Return success code 1 to caller:
   return 1;
} # end sub set

# Print messages only if debugging:
sub BLAT ($string) {if ($Debug) {say STDERR $string} return 1}

# Print statistics for this program run:
sub stats {
   say STDERR '';
   say STDERR "Statistics for directory tree \"$OriDir\":";
   printf STDERR "Navigated %6d directories.        \n", $direcount;
   printf STDERR "Skipped   %6d hidden files.       \n", $hiskcount;
   printf STDERR "Processed %6d files.              \n", $filecount;
   printf STDERR "Opened    %6d files.              \n", $opencount;
   printf STDERR "Failed    %6d file-open attempts. \n", $noopcount;
   printf STDERR "Read      %6d files.              \n", $readcount;
   printf STDERR "Failed    %6d file-read attempts. \n", $nordcount;
   printf STDERR "Set       %6d permissions.        \n", $permcount;
   printf STDERR "Simulated %6d permissions.        \n", $simucount;
   return 1;
} # end sub stats

# Handle errors:
sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but \"$pname\" takes
   no-more-than-2 optional arguments. Help follows:
   END_OF_ERROR
} # end sub error

# Print help:
sub help
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "canononicalize-permissions.pl". This program canonicalizes the
   permissions of non-hidden directory entries (and also hidden items if a -n or
   --hidden option is used). Permissions for directories are set to "rwxrwxr-x";
   things which should be executable are set to "rwxrwxr-x"; text, pictures,
   sounds, and videos are set to "-rw-rw-r--"; and everything else (links,
   pipes, sockets, etc) is left unaltered.

   -------------------------------------------------------------------------------
   Command Lines:

   canoperm.pl -h | --help            (to print this help and exit)
   canoperm.pl [options] [arguments]  (to canonicalize permissions)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:           Meaning:
   -h or --help      Print help and exit.
   -e or --debug     Print diagnostics and simulate permissions.
   -q or --quiet     DON'T print per-file info.                     (DEFAULT)
   -v or --verbose   DO    print per-file info.
   -l or --local     DON'T recurse subdirectories (but not links).  (DEFAULT)
   -r or --recurse   DO    recurse subdirectories (but not links).
   -f or --files     Target files only.
   -d or --dirs      Target directories only.
   -b or --both      Target both files and directories.
   -a or --all       Target all directory entries.                  (DEFAULT)
   -n or --hidden    Also process hidden items.

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively process items.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: henabdfrlvq.

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

   Happy directory tree permissions canonicalizing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
