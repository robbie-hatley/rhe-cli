#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# rehash.pl
# Corrects names of files with incorrect SHA1 file names.
# Written by Robbie Hatley.
# Edit history:
# Thu Apr 10, 2025: Wrote it.
##############################################################################################################

# Pragmas:
use v5.36;
use strict;
use warnings;

# CPAN Modules:
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';

# RH Modules:
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
my $OriDir    = cwd       ; # Original directory.       cwd       Directory on program entry.
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.

# SHA-1 file-name regexp:
my $sha1pat   = qr(^[0-9a-f]{40}(?:-\(\d{4}\))*\.[^.]+$)o;

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire().
my $filecount = 0 ; # Count of files matching target, regexp, and predicate.
my $sha1count = 0 ; # Count of files also matching "$sha1pat".
my $renacount = 0 ; # Count of files renamed.
my $failcount = 0 ; # Count of failed file-rename attempts.

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
      say STDERR "OriDir    = $OriDir";
      say STDERR "Recurse   = $Recurse";
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
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR '';
   }

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   if ($Help) {
      help;
   }
   else {
      $Recurse and RecurseDirs {curdire} or curdire;
      stats;
   }

   # Stop execution timer:
   my $t1 = time;
   my @s1 = localtime($t1);

   # Print exit message if being terse or verbose:
   if ( $Verbose >= 1 ) {
      my $te = $t1 - $t0; my $ms = 1000 * $te;
      printf STDERR "\nNow exiting program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n",
                    $s1[2], $s1[1], $s1[0], 1+$s1[4], $s1[3], 1900+$s1[5];
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
   }

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If user typed more than 2 arguments, and we're not debugging or getting help,
   # then print error and help messages and exit:
   if ( $NA >= 3                 # If number of arguments >= 3
        && !$Debug && !$Help ) { # and we're not debugging and not getting help,
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
   my $cwd = cwd;

   # Announce current working directory if being verbose:
   if ( $Verbose >= 2 ) {
      say STDERR "\nDirectory # $direcount: $cwd\n";
   }

   # Get sorted list of names in $cwd matching target 'F', $RegExp, and $Predicate:
   my @raw = sort {$a cmp $b} readdir_regexp_utf8($cwd, 'F', $RegExp, $Predicate);
   $filecount += scalar(@raw);

   # Winnow-down that list to just those files with names matching "$sha1pat":
   my @sha1names;
   foreach my $name (@raw) {
      if ($Debug) {say STDERR "In winnow. Name = \"$name\"."}
      if ($name =~ m/$sha1pat/) {
         push @sha1names, $name;
      }
   }
   $sha1count += scalar(@sha1names);

   # Send each path to curfile():
   foreach my $name (@sha1names) {curfile(path($cwd, $name))}

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($path) {
   # Get SHA-1 hash for file at $path:
   my $hash = sha1($path);

   # Get dir, name, prefix, and suffix from path:
   my $dir  = get_dir_from_path($path);
   my $name = get_name_from_path($path);
   my $pref = get_prefix($name);
   my $base = denumerate_file_name($pref);
   my $suff = get_suffix($name);

   # If hash matches base, just return 1:
   if ($hash eq $base) {return 1}

   # Otherwise, try to rename file:
   my $raw_new_name = $hash.$suff;
   my $ava_new_name = find_avail_enum_name($raw_new_name, $dir);
   '***ERROR***' eq $ava_new_name
   and ++$failcount
   and say "Couldn't find available new SHA-1 name for \"$path\"."
   and return 0;
   my $new_path = path($dir, $ava_new_name);
   rename_file($path, $new_path)
   and ++$renacount
   and say "Renamed file at \"$path\" to \"$ava_new_name\"."
   and return 1
   or  ++$failcount
   and say "Failed to renamed file at \"$path\" to \"$ava_new_name\"."
   and return 0;
} # end sub curfile

# Print statistics for this program run:
sub stats {
   # If being terse or verbose, print basic stats to STDERR:
   if ( $Verbose >= 1 ) {
      say STDERR '';
      say STDERR "Statistics for running script \"$pname\" on \"$OriDir\" directory tree";
      say STDERR "with target \"F\", regexp \"$RegExp\", and predicate \"$Predicate\":";
      say STDERR "Navigated $direcount directories.";
      say STDERR "Encountered $filecount files matching given target, regexp, and predicate.";
      say STDERR "$sha1count of those files also had SHA1 file names.";
      say STDERR "Renamed $renacount mis-named files.";
      say STDERR "Tried-but-failed to rename $failcount files.";
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

   Welcome to "rehash.pl". This program fixes any incorrect names on files which
   have SHA-1 file names.

   -------------------------------------------------------------------------------
   Command lines:

   rehash.pl -h | --help                      (to print this help and exit)
   rehash.pl [options] [Arg1] [Arg2] [Arg3]   (to correct bad file names)

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

   NOTE: You can't "skip" Arg1 and go straight to Arg2 because your intended Arg2
   would be construed as Arg1! But you can "bypass" Arg1 by using '.+' meaning
   "some characters" which will match every file name.

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


   Happy file-name correcting!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
