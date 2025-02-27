#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# "dirname-test.pl"
# Tests "dirname" function.
# Written by Robbie Hatley.
# Edit history:
# Fri Jun 14, 2024: Wrote it.
##############################################################################################################

use v5.36;
use strict;
use warnings;
use utf8;
use warnings FATAL => 'utf8';

use Cwd;
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
my $Recurse   = 0            ; # Recurse subdirectories?     bool       Be local.
my $Target    = 'A'          ; # Files, dirs, both, all?     F|D|B|A    Process all file types.
my $RegExp    = qr/^.+$/     ; # Regular expression.         regexp     Process all file names.
my $Predicate = 1            ; # Boolean predicate.          bool       Process all file types.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire().
my $filecount = 0 ; # Count of files found which match file-type target and file-name regexp.
my $predcount = 0 ; # Count of files found which also match file-type predicate.

# Accumulations of counters from RH::Dir::GetFiles():
my $totfcount = 0 ; # Count of all directory entries encountered.
my $noexcount = 0 ; # Count of all nonexistent files encountered.
my $ottycount = 0 ; # Count of all tty files.
my $cspccount = 0 ; # Count of all character special files.
my $bspccount = 0 ; # Count of all block special files.
my $sockcount = 0 ; # Count of all sockets.
my $pipecount = 0 ; # Count of all pipes.
my $brkncount = 0 ; # Count of all symbolic links to nowhere
my $slkdcount = 0 ; # Count of all symbolic links to directories.
my $linkcount = 0 ; # Count of all symbolic links to regular files.
my $weircount = 0 ; # Count of all symbolic links to weirdness (things other than files or dirs).
my $sdircount = 0 ; # Count of all directories.
my $hlnkcount = 0 ; # Count of all regular files with multiple hard links.
my $regfcount = 0 ; # Count of all regular files.
my $unkncount = 0 ; # Count of all unknown files.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Set program name:
   my $pname = substr $0, 1 + rindex $0, '/';

   # Process @ARGV:
   argv;

   # Print entry message if being terse or verbose:
   if ( $Verbose >= 1 ) {
      say    STDERR '';
      say    STDERR "Now entering program \"$pname\"." ;
      say    STDERR "\$Db        = $Db"        ;
      say    STDERR "\$Verbose   = $Verbose"   ;
      say    STDERR "\$Recurse   = $Recurse"   ;
      say    STDERR "\$Target    = $Target"    ;
      say    STDERR "\$RegExp    = $RegExp"    ;
      say    STDERR "\$Predicate = $Predicate" ;
   }

   # Process current directory (and all subdirectories if recursing):
   $Recurse and RecurseDirs {curdire} or curdire;

   # Print stats:
   stats;

   # Print exit message if being terse or verbose:
   if ( $Verbose >= 1 ) {
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
      /^-$s*l/ || /^--local$/   and $Recurse =  0     ;
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1     ;
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

   # Announce current working directory if being at-least-somewhat-verbose:
   if ( $Verbose >= 1) {
      say "\nDirectory # $direcount: $cwd\n";
   }

   # Get list of file-info packets in $cwd matching $Target and $RegExp:
   my $curdirfiles = GetFiles($cwd, $Target, $RegExp);

   # If being very-verbose, also accumulate all counters from RH::Dir:: to main:
   if ( $Verbose >= 2 ) {
      $totfcount += $RH::Dir::totfcount; # all directory entries found
      $noexcount += $RH::Dir::noexcount; # nonexistent files
      $ottycount += $RH::Dir::ottycount; # tty files
      $cspccount += $RH::Dir::cspccount; # character special files
      $bspccount += $RH::Dir::bspccount; # block special files
      $sockcount += $RH::Dir::sockcount; # sockets
      $pipecount += $RH::Dir::pipecount; # pipes
      $brkncount += $RH::Dir::slkdcount; # symbolic links to nowhere
      $slkdcount += $RH::Dir::slkdcount; # symbolic links to directories
      $linkcount += $RH::Dir::linkcount; # symbolic links to regular files
      $weircount += $RH::Dir::weircount; # symbolic links to weirdness
      $sdircount += $RH::Dir::sdircount; # directories
      $hlnkcount += $RH::Dir::hlnkcount; # regular files with multiple hard links
      $regfcount += $RH::Dir::regfcount; # regular files
      $unkncount += $RH::Dir::unkncount; # unknown files
   }

   # Process each path that matches $RegExp, $Target, and $Predicate:
   foreach my $file (sort {$a->{Name} cmp $b->{Name}} @$curdirfiles) {
      ++$filecount;
      local $_ = e $file->{Path};
      if (eval($Predicate)) {
         ++$predcount;
         curfile($file);
      }
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($file) {
   # Get path:
   my $path = $file->{Path};

   # Announce path:
   if ( $Db ) {
      say STDOUT "Simulate: $path";
      # (Don't actually DO anything to file at $path.)
   }
   else {
      my $dirname = get_dirname_from_path($path);
      say '';
      say STDOUT "Path:    $path";
      say STDOUT "Dirname: $dirname";
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curfile

# Print statistics for this program run:
sub stats {
   if ( $Verbose >= 1 ) {
      say    STDERR '';
      say    STDERR 'Statistics for this directory tree:';
      say    STDERR "Navigated $direcount directories.";
      say    STDERR "Found $filecount files matching regexp \"$RegExp\" and target \"$Target\".";
      say    STDERR "Found $predcount files which also match predicate \"$Predicate\".";
   }

   if ( $Verbose >= 2) {
      say    STDERR '';
      say    STDERR 'Directory entries encountered in this tree included:';
      printf STDERR "%7u total files\n",                            $totfcount;
      printf STDERR "%7u nonexistent files\n",                      $noexcount;
      printf STDERR "%7u tty files\n",                              $ottycount;
      printf STDERR "%7u character special files\n",                $cspccount;
      printf STDERR "%7u block special files\n",                    $bspccount;
      printf STDERR "%7u sockets\n",                                $sockcount;
      printf STDERR "%7u pipes\n",                                  $pipecount;
      printf STDERR "%7u symbolic links to nowhere\n",              $brkncount;
      printf STDERR "%7u symbolic links to directories\n",          $slkdcount;
      printf STDERR "%7u symbolic links to non-directories\n",      $linkcount;
      printf STDERR "%7u symbolic links to weirdness\n",            $weircount;
      printf STDERR "%7u directories\n",                            $sdircount;
      printf STDERR "%7u regular files with multiple hard links\n", $hlnkcount;
      printf STDERR "%7u regular files\n",                          $regfcount;
      printf STDERR "%7u files of unknown type\n",                  $unkncount;
   }
   return 1;
} # end sub stats

# Handle errors:
sub error ($err_msg) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $err_msg arguments, but this program takes at most
   # arguments, which must be blah blah blah. Help follows:
   END_OF_ERROR
   return 1;
} # end sub error

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "[insert Program Name here]". This program does blah blah blah
   to all files in the current directory (and all subdirectories if a -r or
   --recurse option is used).

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
   -l or --local      DON'T recurse subdirectories.     (DEFAULT)
   -r or --recurse    DO    recurse subdirectories.
   -f or --files      Target Files.
   -d or --dirs       Target Directories.
   -b or --both       Target Both.
   -a or --all        Target All.                       (DEFAULT)
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively process items.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: heabdfrlvtq.

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

   A number of arguments less than 0 will likely rupture our spacetime manifold
   and destroy everything. But if you DO somehow manage to use a negative number
   of arguments without destroying the universe, please send me an email at
   "Hatley.Software@gmail.com", because I'd like to know how you did that!

   But if you somehow manage to use a number of arguments which is an irrational
   or complex number, please keep THAT to yourself. Some things would be better
   for my sanity for me not to know. I don't want to find myself enthralled to
   Cthulhu.

   Happy item processing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
__END__
