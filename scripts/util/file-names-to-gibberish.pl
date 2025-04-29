#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# file-names-to-gibberish.pl
# Renames all files in the current directory (and all subdirectories if a -r or --recurse option is used)
# to strings of 8 random lower-case letters. All file-name information will be lost; only the file bodies
# will remain, with gibberish names.
#
# Edit history:
# Sun May 31, 2015: Wrote first draft.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Tue Dec 11, 2018: Updated comments and warnings.
# Thu Jan 10, 2019: Now no-longer randomizing files with extensions ".ini", ".db", or ".jbf".
# Mon Mar 02, 2020: Added Spotlight, Firefox, and Spotfire modes.
# Sun Mar 08, 2020: "use v5.30;", and now making max 100 attempts to find nonexisting random new name
#                   for each file.
# Fri Nov 20, 2020: Now using sub "find_available_random" from RH::Dir. And, now allowing user to specify
#                   an optional prefix and/or suffix to tack onto file name prefix.
# Sat Nov 21, 2020: Diagnostics now output only if $Db.
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory as
#                   its first argument, target as second, and regexp (instead of wildcard) as third.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Mon Nov 22, 2021: Changed "find_available_random" to "find_avail_rand_name".
# Mon Nov 29, 2021: Simplified curdire().
# Wed Aug 16, 2023: Reduced width from 120 to 110. Upgraded from "v5.32" to "v5.36".
#                   Got rid of "common::sense" (antiquated). Got rid of prototypes. Now using signatures.
#                   Shorted target options from "--target=xxxxx" to just "--xxxxx". Upgraded sub argv.
#                   Made sub error single-purpose. Shortened curfile() by using "and" and "or".
# Mon Aug 21, 2023: An "option" is now "one or two hyphens followed by 1-or-more word characters".
#                   Reformatted debug printing of opts and args to ("word1", "word2", "word3") style.
#                   Inserted text into help explaining the use of "--" as "end of options" marker.
# Tue Aug 29, 2023: Clarified sub argv().
#                   Got rid of "/...|.../" in favor of "/.../ || /.../" (speeds-up program).
#                   Simplified way in which options and arguments are printed if debugging.
#                   Removed "$" = ', '" and "$, = ', '". Got rid of "/o" from all instances of qr().
#                   Changed all "$db" to $Db". Debugging now simulates renames instead of exiting in main.
#                   Removed "no debug" option as that's already default in all of my programs.
#                   Now using "d getcwd" instead of "cwd_utf8". Reverted to using "-9" for "--nine".
#                   $Db now triggers only diagostics and simulation, not entry/exit or stats.
# Thu Oct 03, 2024: Got rid of Sys::Binmode and common::sense; added "use utf8".
# Mon Mar 17, 2025: Renamed to "file-names-to-gibberish.pl", and archived "file-names-to-gib.pl" as being a
#                   duplicate of this program.
# Thu Apr 03, 2025: Now using "utf8::all" and "Cwd::utf8". Got rid of "cwd_utf8", "d", "e".
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

# Setting:      Default Value:   Meaning of setting:           Range:    Meaning of default:
my $Db        = 0            ; # Debug?                        bool      Don't debug.
my $Verbose   = 0            ; # Quiet or Verbose?             0,1       Be quiet.
my $Recurse   = 0            ; # Recurse subdirectories?       bool      Don't recurse.
my $RegExp    = qr/^.+$/     ; # Regexp.                       regexp    Process all file names.
my $Target    = 'F'          ; # Type of files to target       F|D|B|A   Process regular files only.
my $Predicate = 1            ; # Predicate.                    bool      Process all file types.
my $Yes       = 0            ; # Proceed without prompting?    bool      Don't skip prompting.
my $Simulate  = 0            ; # Merely simulate renames?      bool      Don't simulate
my $Nine      = 0            ; # Ignore files with PreLen<9?   bool      Don't skip short-name-length files.
my $Spotlight = 0            ; # Ignore all but Spotlight?     bool      Don't skip all-but-spotlight.
my $Firefox   = 0            ; # Ignore all but Firefox?       bool      Don't skip all-but-firefox.
my $NoReRan   = 0            ; # Ignore ran-name files?        bool      Don't skip random-named files.
my $Prefix    = ''           ; # Prefix.                       string    Prefix is empty string.
my $Suffix    = ''           ; # Suffix.                       string    Suffix is empty string.

# Counts of events:
my $direcount = 0; # Count of directories processed by curdire.
my $filecount = 0; # Count of files matching $RegExp.
my $findcount = 0; # Count of files also matching $Predicate.
my $skipcount = 0; # Count of files skipped because they're ini, db, jbf.
my $ninecount = 0; # Count of files skipped because prefix length < 9.
my $nomacount = 0; # Count of files skipped because NOt MAtching Spotlight or Firefox.
my $norecount = 0; # Count of files skipped because their names are already randomized.
my $candcount = 0; # Count of candidates for renaming.
my $nonacount = 0; # Count of candidates for which no suitable name could be found.
my $simucount = 0; # Count of file renames simulated.
my $renacount = 0; # Count of files renamed.
my $failcount = 0; # Count of failed attempts to rename files.

# ======= SUBROUTINE PRE-DECLARATIONS ========================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM ===============================================================================

{ # begin main
   my $t0 = time;
   argv;
   my $pname = get_name_from_path($0);
   if ( $Verbose ) {
      say STDERR '';
      say STDERR "Now entering program \"$pname\". ";
      say STDERR "Debug     = $Db                  ";
      say STDERR "Verbose   = $Verbose             ";
      say STDERR "Recurse   = $Recurse             ";
      say STDERR "RegExp    = $RegExp              ";
      say STDERR "Target    = $Target              ";
      say STDERR "Predicate = $Predicate           ";
      say STDERR "Yes       = $Yes                 ";
      say STDERR "Simulate  = $Simulate            ";
      say STDERR "Nine      = $Nine                ";
      say STDERR "Spotlight = $Spotlight           ";
      say STDERR "Firefox   = $Firefox             ";
      say STDERR "NoReRan   = $NoReRan             ";
      say STDERR "Prefix    = \'$Prefix\'          ";
      say STDERR "Suffix    = \'$Suffix\'          ";
   }

   unless ( $Yes ) {
      say STDERR '';
      say STDERR 'WARNING: THIS PROGRAM RENAMES ALL TARGETED FILES IN THE CURRENT DIRECTORY';
      say STDERR '(AND IN ALL SUBDIRECTORIES IF -r OR --recurse IS USED) TO RANDOM STRINGS OF';
      say STDERR '8 lower-case LETTERS. ALL INFORMATION CONTAINED IN THE FILE NAMES WILL BE LOST,';
      say STDERR 'AND ONLY THE FILE BODIES WILL REMAIN, WITH GIBBERISH NAMES.';
      say STDERR 'ARE YOU SURE THAT THAT IS WHAT YOU REALLY WANT TO DO???';
      say STDERR 'Press ":" (shift-semicolon) to continue, or any other key to abort.';
      my $char = get_character;
      exit 0 unless ':' eq $char;
   }
   $Recurse and RecurseDirs {curdire} or curdire;

   stats;
   my $ms = 1000 * (time - $t0);
   if ( $Verbose ) {
      say    STDERR '';
      printf STDERR "Now exiting program \"%s\". Execution time was %.3fms.\n", $pname, $ms;
   }
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS =============================================================================

sub argv {
   # Get options and arguments:
   my @opts = ();             # options
   my @args = ();             # arguments
   my $end = 0;               # end-of-options flag
   my $s = '[a-zA-Z0-9]';     # single-hyphen allowable chars (letters, numbers)
   my $d = '[a-zA-Z0-9=.-_]'; # double-hyphen allowable chars (letters, numbers, equal, dot, hyphen, score)
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
      /^-$s*h/ || /^--help$/      and help and exit 777 ;
      /^-$s*e/ || /^--debug$/     and $Db        =  1   ;
      /^-$s*q/ || /^--quiet$/     and $Verbose   =  0   ;
      /^-$s*v/ || /^--verbose$/   and $Verbose   =  2   ;
      /^-$s*l/ || /^--local$/     and $Recurse   =  0   ;
      /^-$s*r/ || /^--recurse$/   and $Recurse   =  1   ;
      /^-$s*f/ || /^--files$/     and $Target    = 'F'  ;
      /^-$s*d/ || /^--dirs$/      and $Target    = 'D'  ;
      /^-$s*b/ || /^--both$/      and $Target    = 'B'  ;
      /^-$s*a/ || /^--all$/       and $Target    = 'A'  ;
      /^-$s*y/ || /^--yes$/       and $Yes       =  1   ;
      /^-$s*s/ || /^--simulate$/  and $Simulate  =  1   ;
      /^-$s*9/ || /^--nine$/      and $Nine      =  1   ;
      /^-$s*n/ || /^--noreran$/   and $NoReRan   =  1   ;
      /^-$s*p/ || /^--spotlight$/ and $Spotlight =  1   ;
      /^-$s*x/ || /^--firefox$/   and $Firefox   =  1   ;
      /^-$s*t/ || /^--spotfire$/  and $Spotlight =  1 and $Firefox = 1;
      length($_) > 9 && substr($_, 0, 9) eq '--prefix=' and $Prefix = substr($_, 9);
      length($_) > 9 && substr($_, 0, 9) eq '--suffix=' and $Suffix = substr($_, 9);
   }
   if ( $Db ) {
      say STDERR '';
      say STDERR "\$opts = (", join(', ', map {"\"$_\""} @opts), ')';
      say STDERR "\$args = (", join(', ', map {"\"$_\""} @args), ')';
   }

   # Process arguments:
   my $NA = scalar(@args);     # Get number of arguments.
   if ( $NA >= 1 ) {           # If number of arguments >= 1,
      $RegExp = qr/$args[0]/o; # set $RegExp to $args[0].
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
   ++$direcount;
   my $cwd = cwd;
   say STDOUT "\nDir # $direcount: $cwd\n";
   my $curdirfiles = GetFiles($cwd, $Target, $RegExp);
   foreach my $file (@$curdirfiles) {
      ++$filecount;
      local $_ = $file->{Path};
      if (eval($Predicate)) {
         ++$findcount;
         curfile($file);
      }
   }
   return 1;
} # end sub curdire

sub curfile ($file) {
   my $path          = $file->{Path};
   my $dire          = get_dir_from_path($path);
   my $name          = $file->{Name};
   my $prefix        = get_prefix($name);
   my $prelen        = length($prefix);
   my $suffix        = get_suffix($name);

   # Announce file name info if debugging:
   if ( $Db ) {
      say STDERR '';
      say STDERR "In curfile(), near top. Just set initial variables:";
      say STDERR "\$path   = $path";
      say STDERR "\$dire   = $dire";
      say STDERR "\$name   = $name";
      say STDERR "\$prefix = $prefix";
      say STDERR "\$prelen = $prelen";
      say STDERR "\$suffix = $suffix";
   }

   # Skip hidden files and directories:
   $name =~ m/^\./
   and ++$skipcount
   and say STDOUT "Skipped file \"$name\" (hidden)."
   and return 1;

   # Skip desktop, thumbs, browse, and id-token files:
   is_data_file($path)
   && $name =~ m/^desktop.*\.ini$|^thumbs.*\.db$|^pspbrwse.*\.jbf$|id-token/i
   and ++$skipcount
   and say STDOUT "Skipped file \"$name\" (desktop, thumbs, browse, or id-token)."
   and return 1;

   # Skip this file if the "Nine" feature is turned on and the prefix length is < 9:
   $Nine && $prelen < 9
   and ++$ninecount
   and say STDOUT "Skipped file \"$name\" because prefix length < 9."
   and return 1;

   # Skip this file if in "Spotlight" mode and file doesn't match sl:
   $Spotlight && !$Firefox && $prefix !~ m/[0-9a-f]{64}/
   and ++$nomacount
   and say STDOUT "Skipped file \"$name\" because not Spotlight."
   and return 1;

   # Skip this file if in "Firefox" mode and file doen't match ff:
   $Firefox && !$Spotlight && $prefix !~ m/[0-9A-F]{40}/
   and ++$nomacount
   and say STDOUT "Skipped file \"$name\" because not Firefox."
   and return 1;

   # Skip this file if in "Spotfire" mode and file doesn't match sl or ff:
   $Spotlight && $Firefox && $prefix !~ m/[0-9a-f]{64}/ && $prefix !~ m/[0-9A-F]{40}/
   and ++$nomacount
   and say STDOUT "Skipped file \"$name\" because not Spotlight or Firefox."
   and return 1;

   # Skip this file if in  "NoReRan" mode and file name is already randomized:
   $NoReRan && $prefix =~ m/\p{Ll}{8}/
   and ++$norecount
   and say STDOUT "Skipped file \"$name\" because already random."
   and return 1;

   # If we get to here, we're about to either simulate a rename or attempt a rename, provided that we can
   # find a suitable name, so increment the candidate counter:
   ++$candcount;

   # Try to find a random file name that doesn't already exist in file's directory:
   my $new_name = find_avail_rand_name($dire, $Prefix, $Suffix . $suffix);
   $Db and say STDERR "In curfile(). \$new_name = $new_name";

   # Check to see if find_avail_rand_name returned an error code:
   '***ERROR***' eq $new_name
   and ++$nonacount
   and say STDOUT "Error: unable to find available name for \"$name\"."
   and return 0;

   # If debugging or simulating, just go through the motions then return 1:
   $Db || $Simulate
   and ++$simucount and say STDOUT "Simulated Rename: $name => $new_name" and return 1;

   # Otherwise, attempt rename:
   rename_file($name, $new_name)
   and ++$renacount and say STDOUT "Renamed: $name => $new_name" and return 1
   or  ++$failcount and say STDOUT "Failed:  $name => $new_name" and return 0;
} # end sub curfile ($file)

sub stats {
   if ( $Verbose ) {
      say STDERR '';
      say STDERR "Statistics for program \"randomize-file-names.pl\":";
      say STDERR "Navigated $direcount directories.";
      say STDERR "Found $filecount files matching target \"$Target\" and regexp \"$RegExp\".";
      say STDERR "Found $findcount files also matching predicate \"$Predicate\".";
      say STDERR "Skipped $skipcount files because they're dsktp, thumbs, pspb, or ID.";
      $Nine and say STDERR "Skipped $ninecount files with prefix length < 9.";
      $Spotlight || $Firefox and say STDERR "Skipped $nomacount files not matching sl and/or ff pattern.";
      $NoReRan and say STDERR "Skipped $norecount files because they already had randomized names.";
      say STDERR "Nominated $candcount candidates for renaming.";
      say STDERR "Rejected $nonacount rename candidates because no suitable names could be found.";
      $Simulate and say STDERR "Simulated $simucount file renames."
      or  say STDERR "Successfully randomized the names of $renacount files."
      and say STDERR "Tried but failed to randomize the names of $failcount files.";
   }
   return 1;
} # end sub stats

sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most 1 argument,
   which, if present, must be a regular expression expressing which file names
   to randomize. Help follows:
   END_OF_ERROR
} # end sub error ($NA)

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "randomize-file-names.pl", Robbie Hatley's file name randomizer.
   This program randomizes file names by replacing the name of each name with a
   random string of 8 lower-case English letters (a-z).

   This program should NOT be run frivolously, because it destroys all information
   contained in the names of all files it processes. However, in cases where you
   have a bunch of files which ALREADY have long, gibberishy names -- such as,
   files scavenged from a browser cache -- then this program is helpful because
   it assigns a unique, random, short name to each file consisting of exactly 8
   lower-case letters, with equal abundance of each possible first letter.
   This aids both in scrolling through files and in processing them with programs,
   as you can clearly see what percentage have been scrolled or processed so-far,
   because there will be roughly equal numbers of names starting with each
   letter of the alphabet.

   -------------------------------------------------------------------------------
   Skipped Files:

   This program doesn't randomize file names matching any of the following regexps:
   $name =~ m/^desktop.*\.ini$/i;
   $name =~ m/^thumbs.*\.db$/i;
   $name =~ m/^pspbrwse.*\.jbf$/i;
   $name =~ m/ID-Token/i;
   That's because because those are system files, only one of which exists in
   any one directory, rather than data files. "desktop.ini" sets the properties
   of the folder; "Thumbs.db" contains Windows picture thumbnails; "pspbrwse.jbf"
   contains Jasc Paint Shop Pro picture thumbnails; and "ID-Token" identifies
   a folder, partition, or computer.

   -------------------------------------------------------------------------------
   Command Lines:

   randomize-file-names.pl  -h | --help              (to print this help and exit)
   randomize-file-names.pl [options] [Arg1] [Arg2]   (to randomize file names)

   -------------------------------------------------------------------------------
   Description of options:

   Option:              Meaning:
   -h or --help         Print help and exit.
   -e or --debug        Print diagnostics and exit.
   -q or --quiet        Be quiet.                       (DEFAULT)
   -v or --verbose      Be verbose.
   -l or --local        Process local files only.       (DEFAULT)
   -r or --recurse      Recurse subdirectories.
   -f or --files        Target Files.
   -d or --dirs         Target Directories.
   -b or --both         Target Both.
   -a or --all          Target All.
   -y or --yes          Randomize file names without prompting.
   -s or --simulate     Merely simulate renames.
   -9 or --nine         Ignore files with prefix length < 9.
   -n or --noreran      Ignore files with names that are already randomized
   -p or --spotlight    Ignore all file names other than spotlight photo names
   -x or --firefox      Ignore all file names other than firefox cache names
   -t or --spotfire     Ignore all file names other than spotlight or firefox
   --prefix=NamePrefix  Tack NamePrefix on beginning of file name
   --suffix=NameSuffix  Tack NameSuffix on end of file name before type suffix

   -h or --help        Print help and exit.
   -l or --local       Don't recurse subdirectories.   (DEFAULT)
   -r or --recurse     Do    recurse subdirectories.

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively process items.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: hetxpn9syabdfrlvq

   If you want to use an argument that looks like an option (say, you want to
   search for files with names containing the substring "-9"), use a "--"
   option; that will force all command-line entries to its right to be construed
   as being "arguments" rather than "options".

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

   (Exception: Technically, you can use an integer as a boolean, and it doesn't
   need quotes or parentheses; but if you use an integer, any non-zero integer
   will process all paths and 0 will process no paths, so this isn't very useful.)

   Arguments and options may be freely mixed, but the arguments must appear in
   the order Arg1, Arg2 (RegExp first, then File-Type Predicate); if you get them
   backwards, they won't do what you want, as most predicates aren't valid regexps
   and vice-versa.

   If the number of arguments is not 0, 1, or 2, this program will print an
   error message and abort.

   Happy file-name randomizing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end help
