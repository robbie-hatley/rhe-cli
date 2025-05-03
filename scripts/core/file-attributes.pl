#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# file-attributes.pl
# Prints attributes of the file (if any) at path ARGV[0].
#
# Edit history:
# Tue Jun 09, 2015: Wrote it.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Mon Dec 18, 2017: Improved comments and help and error messages.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Thu Aug 15, 2024: Width 120->110, upgraded from "v5.32" to "v5.36", removed unnecessary "use" statements.
# Thu Mar 06, 2025: Refactored to provide recursion, and to use regexp and predicate to select files, and
#                   to provide F|D|B|A target selection.
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e".
##############################################################################################################

# ======= PRAGMAS AND MODULES: ===============================================================================

use v5.36;
use utf8;
use Cwd;
use POSIX qw( floor ceil strftime );
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
my $OriDir    = d getcwd  ; # Original directory.       cwd       Directory on program entry.
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $Target    = 'A'       ; # Target                    F|D|B|A   Target all directory entries.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire().
my $filecount = 0 ; # Count of files matching target, regexp, and predicate.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
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
      say STDERR 'Basic settings:';
      say STDERR "OriDir    = $OriDir";
      say STDERR "Recurse   = $Recurse";
      say STDERR "Target    = $Target";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR '';
   }

   # If debugging, print the values of all variables except counters, after processing @ARGV:
   if ( $Debug >= 1 ) {
      say STDERR 'Debug: Values of variables after processing @ARGV:';
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
      say STDERR '';
   }

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   if ($Help) {help}
   else {
      if ($Recurse) {
         my $mlor = RecurseDirs {curdire};
         say "Maximum levels of recursion reached = $mlor";
      }
      else {curdire}
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

# Process @ARGV:
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
   }

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If user typed more than 2 arguments, and we're not debugging,
   # then print error and help messages and exit:
   if ( $NA >= 3 && !$Debug ) {  # If number of arguments >= 3 and we're not debugging,
      error($NA);                # print error message,
      help;                      # and print help message,
      exit 666;                  # and exit, returning The Number Of The Beast.
   }

   # First argument, if present, is a file-selection regexp:
   if ( $NA >= 1 ) {             # If number of arguments >= 1,
      $RegExp = qr/$Args[0]/o;   # set $RegExp to $Args[0].
   }

   # Second argument, if present, is a file-selection predicate:
   if ( $NA >= 2 ) {             # If number of arguments >= 2,
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

   # Get list of paths in $cwd matching $Target and $RegExp:
   my @paths = glob_regexp_utf8($cwd, $Target, $RegExp, $Predicate);

   # Send each path to curfile:
   foreach my $path (@paths) {curfile($path)}

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Print the attributes of a file:
sub curfile ($path) {
   # Increment file counter:
   ++$filecount;

   # Announce path and name:
   say '';
   printf("Path =         %s\n", $path);
   printf("Name =         %s\n", get_name_from_path($path));

   # Bail if file does not exist:
   if ( ! -e e $path ) {
      say "Error: File does not exist.";
      return 0; # Can't get attributes of something that doesn't exist.
   }

   # Determine if file is directory (must do that HERE, above the lstat below, because lstat doesn't give info
   # on a link's TARGET, only on the link itself, and I want to include SYMLINKDs as being "directories"):
   my $is_dir = -d e $path;

   # Get current file's info, using lstat instead of stat, so that for
   # links, we get info for the link ITSELF, rather than what it links to:
   my ($dev, $inode, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime) = lstat e $path;
   # From this point on in this subroutine, use "_" as target of all file test operators, to save time.

   # Is this file a link to something?
   my $is_lnk = -l _;

   # Get and format times:
   my @ModTimeFields = localtime($mtime);
   my @InoTimeFields = localtime($ctime);
   my @AccTimeFields = localtime($atime);
   my $mod_date = strftime('%F',   @ModTimeFields);
   my $mod_time = strftime("%T%Z", @ModTimeFields);
   my $ino_date = strftime('%F',   @InoTimeFields);
   my $ino_time = strftime("%T%Z", @InoTimeFields);
   my $acc_date = strftime('%F',   @AccTimeFields);
   my $acc_time = strftime("%T%Z", @AccTimeFields);

   # Print attributes of this file:
   printf("Inode=         %d\n", $inode);
   printf("Links=         %d\n", $nlink);
   printf("Mod time =     %s on %s\n", $mod_time, $mod_date);
   printf("Inode time =   %s on %s\n", $ino_time, $ino_date);
   printf("Access time =  %s on %s\n", $acc_time, $acc_date);
   printf("Size =         %d\n",   -s _ );
   printf("Empty?         %s\n", ( -z _ ) ? 'Yes' : 'No');
   printf("Readable?      %s\n", ( -r _ ) ? 'Yes' : 'No');
   printf("Writable?      %s\n", ( -w _ ) ? 'Yes' : 'No');
   printf("Executable?    %s\n", ( -x _ ) ? 'Yes' : 'No');
   printf("Plain file?    %s\n", ( -f _ ) ? 'Yes' : 'No');

   printf("Directory?     %s\n", ( -d _ ) ? 'Yes' : 'No');
   printf("Symbolic Link? %s\n", $is_lnk  ? 'Yes' : 'No');
   printf("SYMLINKD?      %s\n", ($is_lnk && $is_dir) ? 'Yes' : 'No');
   printf("Target =       %s\n", readlink(e $path)) if $is_lnk;
   printf("Block special? %s\n", ( -b _ ) ? 'Yes' : 'No');
   printf("Char special?  %s\n", ( -c _ ) ? 'Yes' : 'No');
   printf("Pipe?          %s\n", ( -p _ ) ? 'Yes' : 'No');
   printf("Socket?        %s\n", ( -S _ ) ? 'Yes' : 'No');
   printf("TTY?           %s\n", ( -t _ ) ? 'Yes' : 'No');
   return 1;
} # end sub attr

# Print statistics for this program run:
sub stats {
   say STDERR "\n"
             ."Stats for running \"$pname\" in directory tree \"$OriDir\":\n"
             ."Navigated $direcount directories. Found $filecount files matching\n"
             ."target \"$Target\", regexp \"$RegExp\", and predicate \"$Predicate\".";
   return 1;
} # end sub stats

# Handle errors:
sub error ($NA) {
   print STDERR ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most
   2 arguments (an optional file-selection regexp and an optional
   file-selection predicate). Help follows:
   END_OF_ERROR
   return 1;
} # end sub error

sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "file-attributes.pl", Robbie Hatley's nifty program for
   displaying file attributes.

   -------------------------------------------------------------------------------
   Command lines:

   file-attributes.pl -h | --help               (to print help)
   file-attributes.pl [options] [Arg1] [Arg2]   (to print file attributes)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics.
   -l or --local      DON'T recurse subdirectories.     (DEFAULT)
   -r or --recurse    DO    recurse subdirectories.
   -f or --files      Target Files.
   -d or --dirs       Target Directories.
   -b or --both       Target Both.
   -a or --all        Target All.                       (DEFAULT)
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -eh to print both diagnostics and help.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: heabdfrlvtq.

   If you want to use an argument that looks like an option (say, you want to
   process files which contain "--recurse" as part of their name), use a "--"
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

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
