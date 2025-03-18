#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# list-by-extension.pl
# Prints list of regular files in current directory (and all subdirectories if a "-r" or "--recurse" option is
# used) sorted by name extension.
# Written by Robbie Hatley at unknown date, maybe in 2022.
# Edit history:
# Sun Jun 05, 2022: Wrote this file on this date (give or take a few years).
# Thu Sep 07, 2023: Now prints the "ls -l" list of all regular files in the current directory,
#                   grouped by extension and case-insensitively sorted within each group.
# Thu Aug 15, 2024: -C63; got rid of unnecessary "use" statements.
# Sun Mar 16, 2025: Extreme refactor: Added "use RH::Dir"; added global vars & BEGIN for pname, cmpl_beg,
#                   cmpl_end; added "use" statements for needed CPAN and RH modules; added system var $";
#                   added local vars for settings and counters; added main and subs from "Template.pl";
#                   now recurses directory trees; now has options and arguments and help; now uses RegExp and
#                   predicate.
##############################################################################################################

# Pragmas:
use v5.36;
use utf8;

# CPAN modules:
use Cwd         qw( cwd getcwd );
use Time::HiRes qw( time       );

# RH modules:
use RH::Dir;

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

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 0         ; # Be verbose?               bool      Shhhh!! Be quiet!!
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire().
my $filecount = 0 ; # Count of files matching target and regexp.
my $predcount = 0 ; # Count of files also matching predicate.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub gnfl    ; # Get Name-of-file From Ls-line.
sub ext     ; # Extract extension of file from name.
sub stats   ; # Print statistics.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Start execution timer:
   my $t0 = time;

   # Process @ARGV and set settings:
   argv;

   # Print program entry message if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say STDERR "\nNow entering program \"$pname\" at timestamp $t0.";
      say STDERR '';
   }

   # Also print compilation time if being verbose:
   if ( 2 == $Verbose ) {
      printf(STDERR "Compilation time was %.3fms\n",1000*($cmpl_end-$cmpl_beg));
      say STDERR '';
   }

   # Print the values of all variables if debugging:
   if ( 1 == $Debug ) {
      say STDERR "pname     = $pname";
      say STDERR "cmpl_beg  = $cmpl_beg";
      say STDERR "cmpl_end  = $cmpl_end";
      say STDERR "Options   = (@Opts)";
      say STDERR "Arguments = (@Args)";
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR "Verbose   = $Verbose";
      say STDERR "Recurse   = $Recurse";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR '';
   }

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   $Help and help or ($Recurse and RecurseDirs {curdire} or curdire) and stats;

   # Stop execution timer:
   my $t1 = time;

   # Print exit message if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      my $te = $t1 - $t0; my $ms = 1000 * $te;
      say    STDERR '';
      say    STDERR "Now exiting program \"$pname\" at timestamp $t1.";
      printf STDERR "Execution time was %.3fms.", $ms;
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
      /^--$/                 # "--" = end-of-options marker = construe all further CL items as arguments,
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
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0  ; # Default.
      /^-$s*t/ || /^--terse$/   and $Verbose =  1  ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2  ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0  ; # Default.
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1  ;
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
   # Increment directory counter:
   ++$direcount;

   # Get current working directory:
   my $cwd = d getcwd;

   # Announce current working directory:
   say "\nDirectory # $direcount: $cwd\n";

   # Git "ls -l" listing of current directory:
   my @dir_lines = `/usr/bin/ls -l`; # map {d($_)} `/usr/bin/ls -l`;

   # Make hash of directory lines for regular files only, keyed by file-name extension:
   my %exts;
   for my $line ( @dir_lines ) {
      $line =~ s/[\p{Zs}\p{Cc}]+$//g; # Trim whitespace and control characters (eg, newlines) from line ends.
      next if $line =~ m/^total/;     # Skip "total" line.
      next if $line =~ m/^d/;         # Skip directory lines.
      next if $line =~ m/^l/;         # Skip link lines.
      my $name = gnfl($line);         # Get name.
      if ($Debug) {say "\$name = $name";} # Say name if debugging.
      next if $name !~ m/$RegExp/;    # Skip files not matching $RegExp.
      ++$filecount;                   # If we get to here, file matches $RegExp.
      local $_ = e($name);            # Temporarily set $_ to e($name).

      next if !eval($Predicate);      # Skip files not matching $Predicate.
      ++$predcount;                   # If we get to here, file also matches $Predicate.
      push @{$exts{ext(gnfl($line))}}, $line; # Store line in hash.
   }

   # Print "ls -l" list of regular files in current directory grouped by extension and case-insensitively sorted:
   for my $ext ( sort keys %exts ) {
      say '';
      say "Files with extension \"$ext\":";
      say for sort {fc(gnfl($a)) cmp fc(gnfl($b))} @{$exts{$ext}};
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Extract the name of a file from its "ls -l" directory listing:
sub gnfl ( $line ) {
   # Trim-off all but file name:
   return ($line =~ s/^(.+)( [A-Z][a-z]{2} )([ 123][0-9] )( \d{4} |\d\d:\d\d )(.+)$/$5/r);
}

# Get the "extension" part of a file name:
sub ext ( $name ) {
   my $di = rindex $name, '.';
   return '' if -1 == $di;
   return substr $name, $di+1;
}

# Print statistics for this program run:
sub stats {
   # If being terse or verbose, print basic stats to STDERR:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say    STDERR '';
      say    STDERR "Statistics for \"$pname\":";
      say    STDERR "Navigated $direcount directories.";
      say    STDERR "Found $filecount files matching regexp \"$RegExp\".";
      say    STDERR "Found $predcount files which also match predicate \"$Predicate\".";
   }
   return 1;
} # end sub stats

# Handle errors:
sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most
   2 arguments (an optional file-selection regexp and an optional
   file-selection predicate). Help follows.
   END_OF_ERROR
   return 1;
} # end sub error

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "list-by-extension.pl". This program lists all files in the current
   directory (and all subdirectories if a -r or --recurse option is used) which
   match the given RegExp (".+" by default) and predicate (1 by default) by their
   file name extensions (eg, ".txt", ".pdf", ".jpg", etc). File listings are taken
   directly from a call to Linux system utility "/usr/bin/ls -l" (which gives
   "long" listings of files) but grouped by file name extension (which is NOT one
   of the options of the raw "ls" utility). Each extention group is prefaced by
   a line announcing that group. For example:

   Files with extension "jpg":
   (list of jpg files)

   Files with extension "pdf":
   (list of pdf files)

   Files with extension "txt":
   (list of txt files)

   -------------------------------------------------------------------------------
   Command lines:

   list-by-extension.pl -h | --help               (to print this help and exit)
   list-by-extension.pl [options] [Arg1] [Arg2]   (to list files by extension)

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

   Happy file listing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
