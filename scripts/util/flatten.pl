#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# "flatten.pl"
# Appends the name of the current directory to all files in the current directory (and all subdirectories
# if a -r or --recurse option is used).
# Written by Robbie Hatley.
# Edit history:
# Fri Jun 14, 2024: Wrote it.
# Thu Aug 15, 2024: -C63; got rid of unnecessary "use" statements.
# Mon Mar 10, 2025: Removed extended stats. Removed recursion (results in partial flattening, only 1 level,
#                   rather than the full flattening one might expect). Fixed errors in error().
##############################################################################################################

use v5.36;
use utf8;
use Cwd 'getcwd';
use Time::HiRes 'time';
use RH::Dir;
use RH::Util;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

# ======= GLOBAL VARIABLES: ==================================================================================

our $t0     ; # Seconds since 00:00:00 on Thu Jan 1, 1970.

# ======= START TIMER: =======================================================================================

BEGIN {$t0 = time}

# ======= LEXICAL VARIABLES: =================================================================================

# Setting:      Default Value:   Meaning of Setting:         Range:     Meaning of Default:
my $Db        = 0            ; # Debug?                      bool       Don't debug.
my $Verbose   = 0            ; # Be wordy?                   0,1,2      Be quiet.
my $Target    = 'A'          ; # Files, dirs, both, all?     F|D|B|A    Process all file types.
my $RegExp    = qr/^.+$/     ; # Regular expression.         regexp     Process all file names.
my $Predicate = 1            ; # Boolean predicate.          bool       Process all file types.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire().
my $filecount = 0 ; # Count of files found which match file-type target and file-name regexp.
my $predcount = 0 ; # Count of files found which also match file-type predicate.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Set program name:
   my $pname = substr $0, 1 + rindex $0, '/';

   # Process @ARGV:
   argv;

   # Print entry message if being verbose:
   if ( 2 == $Verbose ) {
      say    STDERR '';
      say    STDERR "Now entering program \"$pname\"." ;
      say    STDERR "\$Db        = $Db"        ;
      say    STDERR "\$Verbose   = $Verbose"   ;
      say    STDERR "\$Target    = $Target"    ;
      say    STDERR "\$RegExp    = $RegExp"    ;
      say    STDERR "\$Predicate = $Predicate" ;
   }

   # Process current directory only:
   curdire;

   # Print stats:
   stats;

   # Print exit message if being terse or verbose:
   if ( 2 == $Verbose ) {
      say    STDERR '';
      say    STDERR "Now exiting program \"$pname\".";
      printf STDERR "Execution time was %.3f seconds.", time - $t0;
   }

   # Exit program, returning success code "0" to caller:
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
      /^-$s*h/ || /^--help$/    and help and exit 777 ;
      /^-$s*e/ || /^--debug$/   and $Db      =  1     ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0     ;
      /^-$s*t/ || /^--terse$/   and $Verbose =  1     ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2     ;
      /^-$s*f/ || /^--files$/   and $Target  = 'F'    ;
      /^-$s*d/ || /^--dirs$/    and $Target  = 'D'    ;
      /^-$s*b/ || /^--both$/    and $Target  = 'B'    ;
      /^-$s*a/ || /^--all$/     and $Target  = 'A'    ;
   }
   if ( $Db ) {
      say STDERR '';
      say STDERR "\$opts = (", join(', ', map {"\"$_\""} @opts), ')';
      say STDERR "\$args = (", join(', ', map {"\"$_\""} @args), ')';
   }

   # Process arguments:
   my $NA = scalar(@args);     # Get number of arguments.

   # Use all arguments as RegExps?
   # my $re; $NA >= 1 and $re = join '|', @args and $RegExp = qr/$re/o;

   # Use positional arguments instead?
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

   # Announce current working directory if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say "\nDirectory # $direcount: $cwd\n";
   }

   # Get list of paths in $cwd matching $Target and $RegExp:
   my @paths = glob_regexp_utf8($cwd, $Target, $RegExp);

   # Process each path that matches $RegExp, $Target, and $Predicate:
   foreach my $path (@paths) {
      ++$filecount;
      local $_ = e $path;
      if (eval($Predicate)) {
         ++$predcount;
         curfile($path);
      }
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($path) {
   # Get the name of the immediate parent directory of the file at this path:
   my $dirname = get_dirname_from_path($path);
   my $oldname = get_name_from_path($path);
   my $newname = $dirname . '_' . $oldname;

   # Announce path:
   if ( $Db ) {
      say STDOUT '';
      say STDOUT 'Simulated rename:';
      say STDOUT "\$oldname = $oldname";
      say STDOUT "\$newname = $newname";
      # (Don't actually DO anything to file at $path.)
   }
   else {
      say STDOUT '';
      say STDOUT 'Attempting to rename file:';
      say STDOUT "\$oldname = $oldname";
      say STDOUT "\$newname = $newname";
      rename_file($oldname, $newname)
      and say STDOUT "Rename succeeded."
      or  say STDOUT "Rename failed.";
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curfile

# Print statistics for this program run:
sub stats {
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say    STDERR '';
      say    STDERR 'Statistics for this directory tree:';
      say    STDERR "Navigated $direcount directories.";
      say    STDERR "Found $filecount files matching regexp \"$RegExp\" and target \"$Target\".";
      say    STDERR "Found $predcount files which also match predicate \"$Predicate\".";
   }
   return 1;
} # end sub stats

# Handle errors:
sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most
   2 optional arguments, which, if present, must be a file-selection
   regexp and a file-type predicate, in that order. Help follows.
   END_OF_ERROR
   return 1;
} # end sub error

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "flatten". This program appends the name of the current directory
   to all items in the current directory using a "_". For example, if the current
   directly is "/apple/orange/banana", containing items "peach", "plum", and
   "pear", then this program would rename those 3 items to "banana_peach",
   "banana_plum", and "banana_pear".

   By default this program renames ALL items in the current directory, but this
   can be modified by using A|F|D|B switches, regexps, and predicates; see
   "options" and "arguments" below.

   Processing of the contents of subdirectories must be done separately, because
   recursing this program wouldn't do what you want (it would only result in
   flattening 1 level deep instead of full flattening).

   -------------------------------------------------------------------------------
   Command lines:

   program-name.pl -h | --help                       (to print this help and exit)
   program-name.pl [options] [Arg1] [Arg2] [Arg3]    (to [perform funciton] )

   -------------------------------------------------------------------------------
   Description of options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics.
   -q or --quiet      Be quiet.                         (DEFAULT)
   -t or --terse      Be terse.
   -v or --verbose    Be verbose.
   -f or --files      Target Files.
   -d or --dirs       Target Directories.
   -b or --both       Target Both.
   -a or --all        Target All.                       (DEFAULT)
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively process items.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: heabdfvtq.

   If you want to use an argument that looks like an option (say, you want to
   flatten files with names starting with "--dirs"), use a "--" option; that
   will force all command-line entries to its right to be considered
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
   the predicate. Here are some examples of valid and invalid predicate arguments:
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

   A number of arguments greater than 2 will cause this program to print an error
   message and abort.

   Happy file name flattening!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
__END__
