#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# fill-files-with-random-bytes.pl
# Fills all (or targeted) regular files in the current working directory (and all of its subdirectories if a
# "-r" or "--recurse" option is used) with 100,000-to-999,999 bytes of random bytes (0 to 255).
# WARNING: THIS PROGRAM WILL DESTROY THE CONTENTS OF ALL OF YOUR FILES!!!
# ARE YOU SURE THAT THAT IS WHAT YOU REALLY WANT TO DO???
# Written by Robbie Hatley.
# Edit history:
# Fri Apr 04, 2025: Wrote it.
##############################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
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
my $Verbose   = 0         ; # Be verbose?               0,1,2     Shhh! Be quiet!
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.
my $OriDir    = cwd       ; # Original directory.       cwd       Directory on program entry.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire().
my $filecount = 0 ; # Count of files processed by curfile().
my $garbcount = 0 ; # Count of files intentionally and irrevocably corrupted by this program.
my $simucount = 0 ; # Count of files we only PRETENDED to corrupt.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
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
   if ( 1 == $Verbose || 2 == $Verbose ) {
      printf STDERR "Now entering program \"%s\" at %02d:%02d:%02d on %d/%d/%d.\n\n",
                    $pname, $s0[2], $s0[1], $s0[0], 1+$s0[4], $s0[3], 1900+$s0[5];
   }

   # Also print compilation time if being verbose:
   if ( 2 == $Verbose ) {
      printf STDERR "Compilation time was %.3fms\n\n",
                    1000 * ($cmpl_end - $cmpl_beg);
   }

   # Print the values of all variables if debugging or being verbose:
   if ( 1 == $Debug || 2 == $Verbose ) {
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
                   "Predicate = $Predicate\n\n";
   }

   # If user wants help, just print help:
   if ($Help) {help}

   # Otherwise, make sure user understands how dangerous this program is, and if they still want to proceed,
   # then process current directory (and all subdirectories if recursing) and print stats:
   else {
      say 'WARNING: THIS PROGRAM WILL DESTROY THE CONTENTS OF ALL OF YOUR FILES!!!';
      say 'ARE YOU SURE THAT THAT IS WHAT YOU REALLY WANT TO DO???';
      say 'PRESS ^ (SHIFT-6) TO CONTINUE OR ANY OTHER KEY TO ABORT.';
      my $character = get_character();
      if ( '^' eq $character ) {
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
      say    STDERR "\nNow exiting program \"$pname\" in directory \"$OriDir\"";
      printf STDERR "at %02d:%02d:%02d on %d/%d/%d. ", $s1[2], $s1[1], $s1[0], 1+$s1[4], $s1[3], 1900+$s1[5];
      printf STDERR "Execution time was %.3fms.", $ms;
   }

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV and set settings:
sub argv {
   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV:
      !$end                  # If we haven't yet reached end-of-options,
      && /^--$/              # and we see an "--" option,
      and $end = 1           # set the "end-of-options" flag
      and push @Opts, '--'   # and push "--" to @Opts
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we get a valid short option
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
   }

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If user typed more than 2 arguments, and we're not debugging or getting help,
   # then print error and help messages and exit:
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
   # Increment directory counter:
   ++$direcount;

   # Get current working directory:
   my $cwd = cwd;

   # Announce current working directory if being verbose:
   if ( 2 == $Verbose) {
      say STDERR "\nDirectory # $direcount: $cwd\n";
   }

   # Get sorted list of paths in $cwd matching $Target, $RegExp, and $Predicate:
   my @paths = sort {$a cmp $b} glob_regexp_utf8($cwd, 'F', $RegExp, $Predicate);

   # Send each path to curfile():
   foreach my $path (@paths) {curfile($path)}

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($path) {
   # Increment file counter:
   ++$filecount;

   # If debugging, just simulate file destruction:
   if ( 1 == $Debug ) {
      # We're in simulation mode, so just PRETEND to destroy file contents:
      say STDOUT "simulating corruption of file \"$path\"";
      ++$simucount;
   }

   # Otherwise, fill current file with garbage:
   else {
      # Fill a buffer with 100_000 to 999_999 random bytes:
      my $size   = 100_000 + int rand 900_000;
      my $buffer = '';
      for (1..$size) {
         $buffer .= chr(int rand 255);
      }
      # Write garbage from buffer to file:
      my $fh = undef;
      open  $fh, '>:raw',  $path or warn "Error: couldn't open  \"$path\".\n" and return 0;
      print $fh $buffer          or warn "Error: couldn't write \"$path\".\n" and return 0;
      close $fh                  or warn "Error: couldn't close \"$path\".\n" and return 0;
      say "Filled file \"$path\" with trash.";
      ++$garbcount;
   }
   # Return success code 1 to caller:
   return 1;
} # end sub curfile

# Print statistics for this program run:
sub stats {
   # If being terse or verbose, print basic stats to STDERR:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say STDERR '';
      say STDERR "Stats for running program \"$pname\" on directory tree \"$OriDir\"";
      say STDERR "with regexp \"$RegExp\" and predicate \"$Predicate\":";
      say STDERR "Navigated $direcount directories.";
      say STDERR "Processed $filecount files matching given regexp and predicate.";
      say STDERR "Intentionally filled $garbcount files with random bytes.";
      say STDERR "Simulated the corruption of $simucount files.";
   }
   return 1;
} # end sub stats

# Handle errors:
sub error ($NA) {
   print STDERR ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most
   2 arguments (an optional file-selection regexp and an optional
   file-selection predicate). Help follows.
   END_OF_ERROR
   return 1;
} # end sub error

# Print help:
sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "fill-files-with-random-bytes.pl". This program fills all (or
   targeted) regular files in the current working directory (and all of its
   subdirectories if a "-r" or "--recurse" option is used) with 100,000-to-999,999
   random bytes (0 to 255).

   The primary purpose of this program is to provide files with random sizes and
   contents in order to test various file-hashing programs. However, it can also
   be used in any other situation where you need files with random contents.

   WARNING: THIS PROGRAM WILL DESTROY THE CONTENTS OF ALL OF YOUR FILES!!!
   ARE YOU SURE THAT THAT IS WHAT YOU REALLY WANT TO DO???

   -------------------------------------------------------------------------------
   Command lines:

   fill-files-with-random-bytes.pl -h | --help     (to print this help)
   fill-files-with-random-bytes.pl [opts] [args]   (to fill files with trash)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics and emulate (don't alter files).
   -q or --quiet      Be quiet. (Default.)
   -t or --terse      Be terse.
   -v or --verbose    Be verbose.
   -l or --local      DON'T recurse subdirectories. (Default.)
   -r or --recurse    DO    recurse subdirectories.
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively randomize files.

   If two piled-together single-letter options conflict, the option
   appearing lowest on the options chart above will prevail.
   If two separate (not piled-together) options conflict, the right
   overrides the left.

   If you want to use an argument that looks like an option (say, you want to
   randomize files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   In addition to options, this program can take 1 or 2 optional arguments.

   Arg1 (OPTIONAL), if present, must be a Perl-Compliant Regular Expression
   specifying which files to randomize. To specify multiple patterns, use the "|"
   alternation operator. To apply pattern modifier letters, use an Extended
   RegExp Sequence. For example, if you want to randomize files with names
   containing "cat", "dog", or "horse", title-cased or not, you could use this:
   fill-files-with-random-bytes.pl '(?i:c)at|(?i:d)og|(?i:h)orse'
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


   Happy file randomizing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
