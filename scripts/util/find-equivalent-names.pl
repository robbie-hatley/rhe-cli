#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# find-equivalent-names.pl
# This program finds directory entries (files and/or directories) in the current directory (and all
# subdirectories if a -r or --recurse option is used) which have names which are the same if all of the
# non-alphanumeric characters are removed and the cases of the letters are folded. For example, this program
# would consider "Josh Bell.mp3", "Josh-Bell.mp3", and "JoSh_bEll.mp3" to have "equivalent" names.
#
# Edit history:
# Wed Oct 17, 2018: Wrote first draft on-or-before this day (exact date unknown; never recorded).
# Tue Aug 04, 2020: Widened to 110; corrected comments; corrected help; v5.30; weeded "use"; etc.
# Thu Aug 06, 2020: Fixed some bugs introduced last Tuesday; now fully functional.
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory as
#                   its first argument, target as second, and regexp (instead of wildcard) as third.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Thu Oct 03, 2024: Got rid of Sys::Binmode and common::sense; added "use utf8".
# Thu Mar 06, 2025: Decreased width from 120 to 110. Increased min ver from "5.32" to "5.36". Refactored to
#                   fix bug in which some "equivalent" names were not being found. Renamed program from
#                   "find-duplicate-names.pl" to "find-equivalent-names.pl". Shebang now uses "-C63".
#                   Got rid of all prototypes and empty signatures.
# Fri Mar 07, 2025: Corrected help.
# Tue Apr 01, 2025: Corrected description above to specify "case-folding" and "non-alphanumeric characters"
#                   instead of just " ", "_", "-". Now announces directory only for those directories which
#                   have clusters of 2-or-more "equivalent" names.
##############################################################################################################

use v5.36;
use utf8;

use Cwd                qw( cwd getcwd   );
use Time::HiRes        qw( time         );
use Switch             qw( :DEFAULT     );

use RH::Util;
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

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 0         ; # Be verbose?               0,1,2     Shhh! Be quiet!
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $Target    = 'A'       ; # Target                    F|D|B|A   Target all directory entries.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.
my $OriDir    = d getcwd  ; # Original directory.       cwd       Directory on program entry.

# Counters:
my $direcount = 0; # Count of directories processed by curdire().
my $filecount = 0; # Count of directory entries matching target, regexp, and predicate.
my $equicount = 0; # Count of equivalent directory name pairs found.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
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
      say    STDERR "\nNow entering program \"$pname\" in cwd \"$OriDir\"";
      printf STDERR "at %d:%02d:%02d on %d/%d/%d.\n", $s0[2], $s0[1], $s0[0], 1+$s0[4], $s0[3], 1900+$s0[5];
      say    STDERR '';
   }

   # Also print compilation time if being verbose:
   if ( 2 == $Verbose ) {
      printf(STDERR "Compilation time was %.3fms\n",1000*($cmpl_end-$cmpl_beg));
      say STDERR '';
   }

   # Print the values of all variables if debugging or being verbose:
   if ( 1 == $Debug || 2 == $Verbose ) {
      say STDERR "pname     = $pname";
      say STDERR "cmpl_beg  = $cmpl_beg";
      say STDERR "cmpl_end  = $cmpl_end";
      say STDERR "Options   = (@Opts)";
      say STDERR "Arguments = (@Args)";
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR "Verbose   = $Verbose";
      say STDERR "Recurse   = $Recurse";
      say STDERR "Target    = $Target";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR '';
   }

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   $Help and help or ($Recurse and RecurseDirs {curdire} or curdire) and stats;

   # Stop execution timer:
   my $t1 = time;
   my @s1 = localtime($t1);

   # Print exit message if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      my $te = $t1 - $t0; my $ms = 1000 * $te;
      say    STDERR '';
      say    STDERR "\nNow exiting program \"$pname\" in cwd \"$OriDir\"";
      printf STDERR "at %d:%02d:%02d on %d/%d/%d. ", $s1[2], $s1[1], $s1[0], 1+$s1[4], $s1[3], 1900+$s1[5];
      printf STDERR "Execution time was %.3fms.", $ms;
   }

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

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
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0  ; # Default.
      /^-$s*t/ || /^--terse$/   and $Verbose =  1  ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2  ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0  ; # Default.
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1  ;
      /^-$s*f/ || /^--files$/   and $Target  = 'F' ;
      /^-$s*d/ || /^--dirs$/    and $Target  = 'D' ;
      /^-$s*b/ || /^--both$/    and $Target  = 'B' ;
      /^-$s*a/ || /^--all$/     and $Target  = 'A' ; # Default.
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

sub curdire {
   # Get current working directory and increment directory counter:
   my $cwd = d getcwd;
   ++$direcount;

   # Read list of all file names from current directory into array "@names" and increment file counter:
   my $dh = undef;
   opendir $dh, e $cwd or die "Fatal error: Couldn't open  directory \"$cwd\".\n$!\n";
   my @names = d(readdir($dh));
   scalar(@names) >= 2 or die "Fatal error: Couldn't read  directory \"$cwd\".\n$!\n";
   closedir $dh or die "Fatal Error: Couldn't close directory \"$cwd\".\n$!\n";
   $filecount += scalar(@names);

   # Make a hash of file names keyed by "reduced" versions of names
   # (case-folded with all non-alphanumeric characters removed):
   my %file_table;
   NAME: for my $name (@names) {
      next if '.'  eq $name;
      next if '..' eq $name;
      next if ! -e e $name;
      my @stats = lstat e $name;
      switch($Target) {
         case 'F' { next NAME if !  -f _            }
         case 'D' { next NAME if !            -d _  }
         case 'B' { next NAME if ! (-f _) || (-d _) }
         else     {                 ;               } # Do nothing
      }
      my $reduced = fc($name =~ s/[^\pL\pN]+//gr);
      push @{$file_table{$reduced}}, $name; # Autovivify!
   }

   # If one-or-more clusters of 2-or-more "equivalent" names exist in this directory, increment equivalence
   # counter by comb(n,2), announce directory, and announce all such clusters:
   my $dir_flag = 0;
   for my $key (sort keys %file_table) {
      my $n = scalar @{$file_table{$key}};
      if ( $n > 1) {
         $equicount += $n*($n-1)/2; # comb(n,2)
         if (!$dir_flag) {
            $dir_flag = 1;
            say "\nDir # $direcount: $cwd";
         }
         say '';
         say 'equivalent:';
         say for @{$file_table{$key}};
      }
   }

   # We're done, so return success code "1" to caller:
   return 1;
} # end sub curdire

sub equiv ($first, $second) {
   $first  =~ s/[^\pL\pN]//g;
   $second =~ s/[^\pL\pN]//g;
   return fc($first) eq fc($second);
} # end sub equiv

sub stats {
   say STDERR "\nStats for program \"find-duplicate-names.pl\":";
   say STDERR "Navigated $direcount directories.";
   say STDERR "Examined $filecount items matching target \"$Target\", regexp \"$RegExp\",";
   say STDERR "and predicate \"$Predicate\".";
   say STDERR "Found $equicount equivalent name pairs.";
   return 1;
} # end sub stats

sub error ($NA) {
   print STDERR ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most one argument,
   which, if present, must be a regular expression specifying which files names
   to process.
   END_OF_ERROR
   return 1;
} # end sub error

sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "find-equivalent-names.pl". This program finds directory entries
   (files and/or directories) in the current directory (and all subdirectories if
   a -r or --recurse option is used) which have names which are the same if all
   of the non-alphanumeric characters are removed and the cases of the letters
   are folded. For example, this program would consider "Josh Bell.mp3",
   "Josh-Bell.mp3", and "JoSh_bEll.mp3" to have "equivalent" names.

   Command line:
   find-equivalent-names.pl [options and/or arguments]

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics.
   -q or --quiet      Be quiet. (Default.)
   -t or --terse      Be terse.
   -v or --verbose    Be verbose.
   -l or --local      DON'T recurse subdirectories. (Default.)
   -r or --recurse    DO    recurse subdirectories.
   -f or --files      Target Files.
   -d or --dirs       Target Directories.
   -b or --both       Target Both.
   -a or --all        Target All. (Default.)
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
   the order Arg1, Arg2 (RegExp first, then Predicate); if you get them backwards,
   they won't do what you want, as most predicates aren't valid regexps and
   vice-versa.

   A number of arguments greater than 2 will cause this program to print an error
   message and abort.


   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
