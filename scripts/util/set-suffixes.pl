#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# set-suffixes.pl
# Sets correct file-name suffixes on files, based on File::Type and on scrutiny of file contents.
# (RENAMES FILES. To just GET correct suffixes, use my program "get-suffixes.pl" instead.)
# Written by Robbie Hatley.
# Edit history:
# Mon May 04, 2015: Wrote first draft.
# Wed May 13, 2015: Updated and changed Help to "Here Document" format.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sun Feb 07, 2015: Made minor improvements.
# Sat Apr 16, 2016: Now using -CSDA.
# Tue Dec 19, 2017: Adjusted formatting, comments, err_msg, help_msg.
# Sun Jan 03, 2021: Edited.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Sat Aug 12, 2023: Reduced width from 120 to 110. Upgraded from "v5.32" to "v5.38". Got rid of
#                   "common::sense" (antiquated). Got rid of all prototypes. Now using signatures.
# Sun Aug 13, 2023: Added section headers to help. Renamed from "set-extensions.pl" to "set-suffixes.pl".
# Sat Sep 02, 2023: Changed all $db to $Debug. Got rid of all "/o" on all qr(). Entry and exit messages are now
#                   always printed to STDERR regardless of $Verbose. Got rid of "--nodebug" as that's already
#                   default. Updated argv. Updated help. Increased parallelism "(g|s)et-suffixes.pl".
#                   Stats now always print to STDERR. Got rid of "quiet" and "verbose" options.
#                   Instead, I'm now using STDERR for messages, stats, diagnostics, STDOUT for dirs/files.
# Wed Jul 31, 2024: Added both :prototype() and signatures () to all subroutines.
# Thu Aug 15, 2024: -C63; Width 120->110; erased unnecessary "use ..."; added protos & sigs to all subs.
# Thu Mar 13, 2025: Got rid of all prototypes. Added predicate.
# Mon May 05, 2025: Updated with latest changes from RH::Dir::get_correct_suffix() in-mind.
# Fri Dec 26, 2025: Re-reverted to "#!/usr/bin/env perl", "use utf8::all", "use Cwd::utf8".
#                   Moved from "core" to "util". Deleted "core".
##############################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
use File::Type;
use RH::Dir;
use Switch;

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
my $Verbose   = 0         ; # Be verbose?               bool      Shhhh!! Be quiet!!
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $OriDir    = cwd       ; # Original directory.       cwd       Directory on program entry.
# (It doesn't make sense for this program to have a "$Target" variable because it deals only with data files.)
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.

# Counters:
my $direcount = 0; # Count of directories processed.
my $filecount = 0; # Count of files processed.
my $errocount = 0; # Count of files which were inaccessible.
my $nondcount = 0; # Count of non-data files encountered.
my $metacount = 0; # Count of meta files encountered.
my $assucount = 0; # Count of files of assumed type.
my $unkncount = 0; # Count of files of unknown type.
my $knowcount = 0; # Count of files of known type.
my $samecount = 0; # Count of files with new name same as old.
my $diffcount = 0; # Count of files with new name different from old.
my $renacount = 0; # Count of files successfully renamed.
my $failcount = 0; # Count of failed file-rename attempts.

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
      say STDERR 'Basic settings:';
      say STDERR "OriDir    = $OriDir";
      say STDERR "Recurse   = $Recurse";
      # (No "$Target" because dealing only with data files.)
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
      # (No "$Target" because dealing only with data files.)
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
         say "\nMaximum levels of recursion reached = $mlor";
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

# ======= SUBROUTINE DEFINITIONS =============================================================================

# Process @ARGV:
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

   # If user typed more than 2 arguments, and we're not debugging, print error and help messages and exit:
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
   ++$direcount;
   my $curdir = cwd;
   say STDOUT '';
   say STDOUT "Directory # $direcount: $curdir";
   say STDOUT '';
   my @paths = glob_regexp_utf8($curdir, 'F', $RegExp, $Predicate);
   foreach my $path (@paths) {curfile($path)}
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($old_path) {
   ++$filecount;
   my $old_name = get_name_from_path ($old_path);
   my $old_dire = get_dir_from_path  ($old_path);
   my $old_pref = get_prefix         ($old_name);
   my $old_suff = get_suffix         ($old_name);
   my $new_pref = $old_pref;
   my $new_suff = get_correct_suffix ($old_path);
   my $new_name = $old_pref . $new_suff;
   my $new_path = path($old_dire, $new_name);

   # Take different actions depending on what $new_suff is:
   switch ($new_suff) {
      # Error:
      case '***ERROR***' {
         ++$errocount;
         say "Error:     \"$old_name\" is not accessible.";
      }
      # Non-data:
      case '***NON-DATA***' {
         ++$nondcount;
         say "Non-Data:  \"$old_name\" is not a data file.";
      }
      # Meta:
      case '***META***' {
         ++$metacount;
         say "Meta:      \"$old_name\" is a meta file.";
      }
      # Assumed:
      case '***ASSUMED***' {
         ++$assucount;
         say "Assumed:   \"$old_name\" is assumed correct (unable to verify).";
      }
      # Unknown:
      case '.unk' {
         ++$unkncount;
         # Correct:
         if ($new_suff eq $old_suff) {
            ++$samecount;
            say "Unknown:   \"$old_name\"";
         }
         # Incorrect:
         else {
            ++$diffcount;
            print "Unknown:   \"$old_name\" => \"$new_name\"";
            rename_file($old_path, $new_path) and ++$renacount and say " (rename succeeded)"
            or ++$failcount and say " (rename failed)";
         }
      }
      # Known (we WERE able to definitively determine the type of this file:):
      else {
         ++$knowcount;
         # Correct:
         if ($new_suff eq $old_suff) {
            ++$samecount;
            say "Correct:   \"$old_name\"";
         }
         # Incorrect:
         else {
            ++$diffcount;
            print "Incorrect: \"$old_name\" => \"$new_name\"";
            rename_file($old_path, $new_path) and ++$renacount and say " (rename succeeded)"
            or ++$failcount and say " (rename failed)";
         }
      } # end else (known type)
   } # end switch ($new_suff)

   # Return success code 1 to caller:
   return 1;
} # end sub curfile

# Print statistics:
sub stats {
   say STDERR "\n"
             ."Stats for running program \"$pname\" on dir tree \"$OriDir\":\n"
             ."Navigated $direcount directories and encountered $filecount files.\n"
             ."Found $errocount inaccessible files.\n"
             ."Found $nondcount non-data files.\n"
             ."Found $metacount meta files.\n"
             ."Found $assucount files of assumed (unverified) type.\n"
             ."Found $unkncount files of unknown type.\n"
             ."Found $knowcount files of known type.\n"
             ."Found $samecount files with correct suffix.\n"
             ."Found $diffcount files with  wrong  suffix.\n"
             ."Successfully renamed $renacount files.\n"
             ."Tried but failed to rename $failcount files.";
   return 1;
} # end sub stats

# Handle errors:
sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most two arguments
   which, if present, must be a regular expression describing which items to
   process and a boolean file-type predicate. Help follows.
   END_OF_ERROR
   return 1;
} # end sub error

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "set-suffixes.pl", Robbie Hatley's nifty file name extension
   setter. This program determines the types of the files in the current directory
   (and all subdirectories if a -r or --recurse option is used) then displays the
   original file names, then, if the original suffix was incorrect, it also sets
   and displays the file's name with the correct suffix. For example, if a file
   is named "cat.txt", but the file is actually a jpg file, this program will
   rename the file to "cat.jpg".

   Note that this program DOES alter the names of files. To just DISPLAY the
   correct file names, use my program "get-suffixes.pl" instead.

   -------------------------------------------------------------------------------
   Command lines:

   set-extensions.pl [-h|--help]            (to print this help and exit)
   set-extensions.pl [options] [argument]   (to set file-name extensions)

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

   Arguments and options may be freely mixed, but the arguments must appear in
   the order Arg1, Arg2 (RegExp first, then File-Type Predicate); if you get them
   backwards, they won't do what you want, as most predicates aren't valid regexps
   and vice-versa.

   A number of arguments greater than 2 will cause this program to print an error
   message and abort.

   Happy suffix setting!

   Cheers,
   Robbie Hatley,
   Programmer.
   END_OF_HELP
   return 1;
} # end sub help
