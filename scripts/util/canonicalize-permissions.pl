#!/usr/bin/env -S perl -C63

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
# Wed Aug 09, 2023: Dramatically symplified permission-setting. Created new subs "set_navi", "set_exec", and
#                   "set_noex". Added several new suffixes. Now handles makefiles (noex).
# Fri Aug 25, 2023: Added "quiet" and "verbose" options to control output. Added "nodebug" option.
#                   Fixed bug in which all image files were having their perms set TWICE.
#                   Added stipulation that this program does not process hidden files.
# Wed Aug 30, 2023: Entry & Exit messages are now controlled by $Verbose only, not $Db.
# Thu Aug 31, 2023: Clarified sub argv().
#                   Got rid of "/...|.../" in favor of "/.../ || /.../" (speeds-up program).
#                   Simplified way in which options and arguments are printed if debugging.
#                   Removed "$" = ', '" and "$, = ', '". Got rid of "/o" from all instances of qr().
#                   Changed all "$db" to $Db". Debugging now simulates renames instead of exiting in main.
#                   Removed "no debug" option as that's already default in all of my programs.
#                   Variable "$Verbose" now means "print per-file info", and default is to NOT do that.
#                   STDERR = "stats and serious errors". STDOUT = "file permissions set, and dirs if verbose".
# Wed Sep 06, 2023: Predicate now overrides target and forces it to 'A' to avoid conflicts with predicate.
# Wed Aug 14, 2024: Removed unnecessary "use" statements.
# Tue Mar 04, 2025: Shebang is now "#!/usr/bin/env -S perl -C63". Nixed "__END__" marker.
##############################################################################################################

use v5.36;
use utf8;
use Cwd;
use Time::HiRes 'time';
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv     ; # Process @ARGV.
sub curdire  ; # Process current directory.
sub set_navi ; # Set a directory to "navigable".
sub set_exec ; # Set a file to "executable".
sub set_noex ; # Set a file to "NOT executable".
sub curfile  ; # Process current file.
sub stats    ; # Print statistics.
sub error    ; # Handle errors.
sub help     ; # Print help and exit.

# ======= VARIABLES: =========================================================================================

# Settings:     Default:       Meaning of setting:           Range:    Meaning of default:
my $Db        = 0          ; # Print diagnostics?            bool      Don't print diagnostics.
my $Verbose   = 0          ; # Print stats?                  bool      Don't print stats.
my $Recurse   = 0          ; # Recurse subdirectories?       bool      Don't recurse.
my $RegExp    = qr/^.+$/   ; # Regular Expression.           regexp    Process all file names.
my $Target    = 'A'        ; # Files, dirs, both, all?       F|D|B|A   Process regular files only.
my $Predicate = 1          ; # Boolean file-type predicate.  bool      Process files of all types.
my $Hidden    = 0          ; # Also process hidden items?    bool      Don't process hidden items.

# Counters:
my $direcount = 0          ; # Count of directories processed by curdire().
my $filecount = 0          ; # Count of dir entries matching $RegExp and $Target
my $predcount = 0          ; # Count of dir entries also matching $Predicate.
my $hidncount = 0          ; # Count of all hidden entries encountered.
my $opencount = 0          ; # Count of all regular files we could    open.
my $noopcount = 0          ; # Count of all regular files we couldn't open.
my $readcount = 0          ; # Count of all regular files we could    read.
my $nordcount = 0          ; # Count of all regular files we couldn't read.
my $permcount = 0          ; # Count of all permissions set.
my $simucount = 0          ; # Count of all simulated setting of permissions.

# ======= MAIN BODY OF PROGRAM: ==============================================================================
{ # begin main
   my $t0 = time;
   my $pname = get_name_from_path($0);
   argv;
   say    STDERR '';
   say    STDERR "Now entering program \"$pname\"." ;
   say    STDERR "\$Db        = $Db"                ;
   say    STDERR "\$Verbose   = $Verbose"           ;
   say    STDERR "\$Recurse   = $Recurse"           ;
   say    STDERR "\$RegExp    = $RegExp"            ;
   say    STDERR "\$Target    = $Target"            ;
   say    STDERR "\$Predicate = $Predicate"         ;
   say    STDERR "\$Hidden    = $Hidden"            ;

   # Run sub curdire() for desired directories:
   $Recurse and RecurseDirs {curdire} or curdire;

   # Print closing newline if we've just been printing $direcount repeatedly on top of itself:
   print STDOUT "\n" if !$Verbose && !$Db;

   stats;
   say    STDERR '';
   say    STDERR "Now exiting program \"$pname\".";
   printf STDERR "Execution time was %.3f seconds.", time - $t0;
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV :
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
      /^-$s*h/ || /^--help$/    and help and exit 777 ;
      /^-$s*e/ || /^--debug$/   and $Db      =  1     ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0     ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  1     ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0     ;
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1     ;
      /^-$s*f/ || /^--files$/   and $Target  = 'F'    ;
      /^-$s*d/ || /^--dirs$/    and $Target  = 'D'    ;
      /^-$s*b/ || /^--both$/    and $Target  = 'B'    ;
      /^-$s*a/ || /^--all$/     and $Target  = 'A'    ;
      /^-$s*n/ || /^--hidden$/  and $Hidden  =  1     ;
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
   # Increment directory counter:
   ++$direcount;

   # Get current working directory:
   my $cwd = d getcwd;
   # Announce current working directory:
   if ( $Verbose || $Db ) {
      say STDOUT "\nDirectory # $direcount: $cwd\n";
   }
   else {
      if ( 1 == $direcount ) {
         printf STDOUT "\nDirectory # %6d", $direcount;
      }
      else {
         printf STDOUT "\b\b\b\b\b\b%6d", $direcount;
      }
   }


   # Get list of file-info packets in $cwd matching $Target and $RegExp:
   my $curdirfiles = GetFiles($cwd, $Target, $RegExp);

   # Send each file that matches $RegExp, $Target, and $Predicate to curfile():
   foreach my $file (@$curdirfiles) {
      # Count ALL files, even ones we skip (because hidden or doesn't match predicate), in $filecount:
      ++$filecount;
      # Don't process hidden items unless user requests that:
      if ( '.' eq substr($file->{Name}, 0, 1) && ! $Hidden ) {
         ++$hidncount;
         next;
      }
      # If we're NOT skipping this item, if it matches predicate, increment $predcount and send it to curfile:
      local $_ = e $file->{Path};
      if (eval($Predicate)) {
         ++$predcount;
         curfile($file);
      }
   }
   return 1;
} # end sub curdire

# Set a directory to "navigable":
sub set_navi ($file) {
   # If debugging, just simulate:
   if ( $Db ) {
      ++$simucount;
      say STDOUT "Simulation: would have set directory \"$file->{Name}\" to navigable.";
   }

   # Else if NOT debugging, change permissions:
   else {
      ++$permcount;
      chmod 0775, e($file->{Path});
      if ( $Verbose ) {
         say STDOUT "Set directory \"$file->{Name}\" to navigable.";
      }
   }
}

# Set a file to "executable":
sub set_exec ($file) {
   # If debugging, just simulate:
   if ( $Db ) {
      ++$simucount;
      say STDOUT "Simulation: would have set file \"$file->{Name}\" to executable.";
   }

   # Else if NOT debugging, change permissions:
   else {
      ++$permcount;
      chmod 0775, e($file->{Path});
      if ( $Verbose ) {
         say STDOUT "Set file \"$file->{Name}\" to executable.";
      }
   }
}

# Set a file to "not executable":
sub set_noex ($file) {
   # If debugging, just simulate:
   if ( $Db ) {
      ++$simucount;
      say STDOUT "Simulation: would have set file \"$file->{Name}\" to NOT-executable.";
   }

   # Else if NOT debugging, change permissions:
   else {
      ++$permcount;
      chmod 0664, e($file->{Path});
      if ( $Verbose ) {
         say STDOUT "Set file \"$file->{Name}\" to NOT-executable.";
      }
   }
}

# Process current file:
sub curfile ($file) {
   # If this is a directory, set it to "navigable":
   if    ( 'D' eq $file->{Type} ) {
      set_navi($file);
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
         say STDERR "Debug msg in canoperm, in curfile: file $file->{Name} has suffix \"$lsuf\"." if $Db;
         for ( $lsuf ) {
            # Scripts in known languages need to be executable:
            # NOTE RH 2024-09-06: I removed "au3", "bat", "ps1", "vbs" because from the standpoint of Linux,
            # such files should NOT be considered "executable" because they're DOS/Windows, not Linux.
            # I also added "elf" and "run" as these ARE executable Linux files.
            if ( /^(apl|awk|elf|pl|perl|py|raku|run|sed|sh)$/ ) {
               set_exec($file);
            }

            # Files with any other non-blank suffixes do NOT need to be executable:
            else {
               set_noex($file);
            }
         }
      }

      # Else if $lsuf is blank, try to open the file and grab its first 4 bytes:
      else {
         say STDERR "Debug msg in canoperm, in curfile: file $file->{Name} has blank suffix." if $Db;
         my $buffer = ''    ;
         my $fh     = undef ;
         my $bytes  = 0     ;
         if ( open($fh, '< :raw', e $file->{Path}) ) {
            ++$opencount;
            if ( read($fh, $buffer, 4) ) {
               $bytes = length($buffer);
               say "Debug msg in canoperm, in curfile: Read $bytes bytes from file \"$file->{Name}\"." if $Db;
            }
            close($fh);
         }
         else {
            ++$noopcount;
         }

         # If we managed to grab the first 128 bytes of data from the file, make a decision based on that:
         if ( 4 == $bytes ) {
            ++$readcount;
            if ( '#!' eq substr($buffer, 0, 2) ) {             # Hashbang script.
               say STDERR "Debug msg in canoperm, in curfile: file $file->{Name} is a hashbang script" if $Db;
               set_exec($file);                                # Set it to "executable".
            }
            elsif ( "\x{7F}ELF" eq substr($buffer, 0, 4) ) {   # Linux ELF "executable".
               say STDERR "Debug msg in canoperm, in curfile: file $file->{Name} is an ELF executable" if $Db;
               set_exec($file);                                # Set it to "executable".
            }
            else {                                             # Data file.
               say STDERR "Debug msg in canoperm, in curfile: file $file->{Name} is a datafile" if $Db;
               set_noex($file);                                # Set it to "NOT executable".
            }
         }

         # Else if we did NOT manage to read the first 128 bytes of data from the file, don't mess with it:
         else {
            ++$nordcount;
            say STDERR "Debug msg in canoperm, in curfile: couldn't read file $file->{Name}" if $Db;
            ; # Do nothing.
         }
      } # end else ($lsuf is blank)
   } # end if (regular file)

   # For things OTHER THAN hidden files, regular files, and directories, do nothing:
   else {
      say STDERR "Debug msg in canoperm, in curfile: file \"$file->{Name}\" is one of the weird ones." if $Db;
      ; # Do nothing.
   } # end else (neither dir nor file)

   # Return success code 1 to caller:
   return 1;
} # end sub curfile ($file)

# Print statistics for this program run:
sub stats {
   say STDERR '';
   say STDERR "Statistics for this directory tree:";
   say STDERR "Navigated $direcount directories.";
   say STDERR "Processed $filecount directory entries matching regexp and target.";
   say STDERR "Found $predcount directory entries also matching predicate.";
   say STDERR "Skipped $hidncount hidden directory entries.";
   say STDERR "Was able to open $opencount regular files with unknown or missing file-name extensions.";
   say STDERR "Failed $noopcount file-open attempts.";
   say STDERR "Was able to read $readcount regular files with unknown or missing file-name extensions.";
   say STDERR "Failed $nordcount file-read attempts.";
   say STDERR "Set $permcount permissions.";
   say STDERR "Simulated $simucount permissions set.";
   return 1;
} # end sub stats

# Handle errors:
sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most 1 argument,
   which, if present, must be a Perl-Compliant Regular Expression specifying
   which directory entries to process. Help follows:
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
