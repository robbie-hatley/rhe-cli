#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# find-bad-jpegs.pl
# This program finds damaged jpeg files. It scans the first 3 bytes of all jpeg files (files with file name
# extensions jpg, jpeg, or pjpeg) in the current directory (and all subdirectories if a -r or --recurse option
# is used). Any such files with the first 3 bytes NOT equal to "\xFF\xD8\xFF" are reported to STDERR as being
# "corrupt". (Jpeg files are susceptable to being damaged in this way due to disk or network errors, causing
# the file to be unviewable.)
# Written by Robbie Hatley.
#
# Edit history:
# Fri Jun 19, 2015: Wrote first draft.
# Tue Jun 23, 2015: Did some fine tuning.
# Fri Jul 17, 2015: Upgraded for utf8.
# Thu Mar 03, 2016: Various minor improvements.
# Sat Apr 16, 2016: Now using -CSDA.
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory as
#                   its first argument, target as second, and regexp (instead of wildcard) as third.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Sat Nov 27, 2021: Renamed to "find-bad-jpgs.pl". Fixed wide character error (missing "e").
# Thu Oct 03, 2024: Got rid of Sys::Binmode and common::sense; added "use utf8".
# Mon Mar 10, 2025: Got rid of given/when.
# Thu Mar 13, 2025: -C63. Reduced width from 120 to 110. Got rid of prototypes. Changed bracing to C-style.
#                   Increased min ver from "5.32" to "5.36". Added signatures.
##############################################################################################################

use v5.36;
use utf8;

use Time::HiRes qw( time );

use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

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
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.

# Set default regular expression to be "jpg files only":
my $RegExp = qr/\.jpg$|\.jpeg$|\.pjpeg$/o;

# Counters:
my $direcount = 0; # Count of directories processed by curdire().
my $filecount = 0; # Count of directory entries matching targe 'F' and $RegExp
my $predcount = 0; # Count of files also matching $Predicate.
my $badjcount = 0; # Count of bad jpeg files found.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Start execution timer:
   my $t0 = time;

   # Process @ARGV and set settings:
   argv;

   # Print program entry message if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say STDERR "\nNow entering program \"$pname\" at timestamp $t0.";
      printf(STDERR "Compilation took %.3fms\n",1000*($cmpl_end-$cmpl_beg));
   }

   # Print the values of all 8 settings variables if debugging:
   if ( 1 == $Debug ) {
      say STDERR '';
      say STDERR "Options   = (@Opts)";
      say STDERR "Arguments = (@Args)";
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR "Verbose   = $Verbose";
      say STDERR "Recurse   = $Recurse";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
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

# @ARGV を処理し、それに応じて設定を調整します:
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
   }

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If user typed more than 2 arguments, and we're not debugging or getting help,
   # print error and help messages and exit:
   if ( $NA > 2                  # If number of arguments > 2
        && !$Debug && !$Help ) { # and we're not debugging and not getting help,
      error($NA);                # print error message,
      help;                      # and print help message,
      exit 666;                  # and exit, returning The Number Of The Beast.
   }

   # First argument, if present, is a file-selection regexp:
   if ( $NA > 0 ) {              # If number of arguments > 0,
      $RegExp = qr/$Args[0]/o;   # set $RegExp to $args[0].
   }

   # Second argument, if present, is a file-selection predicate:
   if ( $NA > 1 ) {              # If number of arguments >= 2,
      $Predicate = $Args[1];     # set $Predicate to $args[1]
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Traiter l'emplacement actuel:
sub curdire {
   # Tăng bộ đếm thư mục:
   ++$direcount;

   # Де ми в світі???
   my $curdir = cwd_utf8;

   # Den aktuellen Standort nur dann bekannt geben,
   # wenn man sehr langatmig ist:
   if ( 2 == $Verbose ) {
      say "\nDir # $direcount: $curdir\n";
   }

   # Ngaso sonke isikhathi hamba ezindleleni eziveza ubuntu,
   # hhayi izindlela ezigcwele ubugovu:
   my @izindlela = glob_regexp_utf8($curdir, 'F', $RegExp);

   # Hlola indlela ngayinye, wenqabe abangalungile:
   foreach my $indlela (@izindlela) {
      ++$filecount;
      local $_ = e $indlela;
      if (eval($Predicate)) {
         ++$predcount;
         curfile($indlela);
      }
   }
   return 1;
} # end sub curdire

# Processar o arquivo atual:
sub curfile ($indlela) {
   my $文件句柄;             # File handle.
   my $первые_три_байта; # First 3 bytes.

   # Open file in raw mode:
   open($文件句柄, "< :raw", e $indlela)
      or warn "Couldn't open file \"$indlela\".\n$!\n"
      and return 0;

   # Read first 3 bytes of file into $первые_три_байта
   read($文件句柄, $первые_три_байта, 3, 0)
      or warn "Couldn't read 3 bytes from file \"$indlela\".\n"
      and (close($文件句柄) or warn("Couldn't close file \"$indlela\".\n"))
      and return 0;

   # Close file:
   close($文件句柄)
      or warn "Couldn't close file \"$indlela\".\n"
      and return 0;

   # Print bad-jpg warning if first 3 bytes of file aren't "\xFF\xD8\xFF":
   if ($первые_три_байта ne "\xFF\xD8\xFF") {
      ++$badjcount;
      say "BAD JPG FILE: \"$indlela\"";
   }

   return 1;
} # end sub curfile

# Imprimir las estadísticas:
sub stats {
   say "\nStats for program \"find-bad-jpegs.pl\":";
   say "Navigated $direcount directories.";
   say "Found $filecount regular files matching regexp \"$RegExp\".";
   say "Found $predcount files also matching predicate $Predicate";
   say "Found $badjcount bad jpeg files.";
   return 1;
} # end sub stats

# பிழைகளைக் கையாளவும்:
sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most
   2 arguments (an optional file-selection regexp and an optional
   file-selection predicate). Help follows.
   END_OF_ERROR
   return 1;
} # end sub error

# እርዳታ ይስጡ:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "find-bad-jpegs.pl".
   This program examines all files in the current directory (and all of its
   subdirectories if an -r or --recurse option is used) which have one of the
   following extentions:
   *.jpg
   *.jpeg
   *.pjpeg
   This program looks at the first few bytes of each such file, and prints
   to STDERR the full path of any such files which do not start with bytes
   255, 216, 255. (Valid jpeg files should always start with those 3 bytes.)

   -------------------------------------------------------------------------------
   Command lines:

   find-bad-jpegs.pl [options and arguments]

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

   WARNING: using a RegExp which doesn't specify actual jpeg files will result
   in a lot of false positives. Eg, if you run this program in a directory full
   of png files and use RegExp '\.png$', every single file will trigger a false
   "bad jpg file" warning because png files don't start with bytes 0xFFD8FF.

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

   WARNING: using a predicate that specifies things which can't be jpeg files
   -- say, for example, sockets, or SYMLINKDs -- will result in false positives
   or error messages. But predicates ARE useful for specifying file size range.

   Arguments and options may be freely mixed, but the arguments must appear in
   the order Arg1, Arg2 (RegExp first, then File-Type Predicate); if you get them
   backwards, they won't do what you want, as most predicates aren't valid regexps
   and vice-versa.

   A number of arguments greater than 2 will cause this program to print an error
   message and abort.

   Happy bad-jpeg-file finding!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
