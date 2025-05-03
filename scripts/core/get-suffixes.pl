#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# get-suffixes.pl
# Gets correct file-name suffixes on regular files, based on File::Type and on scrutiny of file contents.
# (Doesn't rename any files. To set correct suffixes, use my program "set-suffixes.pl" instead.)
# Written by Robbie Hatley.
# Edit history:
# Sat Aug 12, 2023: Wrote it. (STUBB!!!)
# Sun Aug 13, 2023: Fleshed-out help section. Renamed to "get-suffixes.pl". No-longer skips files < 50 bytes.
#                   Changed all "warn" to "say STDERR" and all "say" and "print" to "say STDOUT".
#                   Changed file-renaming code to file-name-printing code. Made fully-functional.
# Sat Sep 02, 2023: Changed all $db to $Debug. Got rid of all "/o" on all qr(). Entry and exit messages are
#                   now always printed to STDERR regardless of $Verbose. Got rid of "--nodebug" as that's
#                   already default. Updated argv. Updated help. Increased parallelism "(g|s)et-suffixes.pl".
#                   Stats now always print to STDERR. Got rid of "quiet" and "verbose" options.
#                   Instead, I'm now using STDERR for messages, stats, diagnostics, STDOUT for dirs/files.
# Thu Aug 15, 2024: -C63; Width 120->110; erased unnecessary "use ..."; added protos & sigs to all subs.
# Thu Mar 13, 2025: Got rid of all prototypes. Added predicate.
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e".
##############################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
use File::Type;
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

# Event counters:
my $direcount = 0; # Count of directories processed.
my $filecount = 0; # Count of files processed.
my $typecount = 0; # Count of files of known type.
my $unkncount = 0; # Count of files of unknown type.
my $samecount = 0; # Count of files with new name same as old.
my $diffcount = 0; # Count of files with new name different from old.



# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ;
sub curdire ;
sub curfile ;
sub stats   ;
sub error   ;
sub help    ;

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

# ======= SUBROUTINE DEFINITIONS =============================================================================

# Process @ARGV and set settings:
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
      $Predicate = $Args[1];     # set $Predicate to $args[1].
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
   my @paths = glob_regexp_utf8($curdir, 'F', $RegExp);
   foreach my $path (@paths) {
      next unless is_data_file($path);
      local $_ = $path;
      if (eval($Predicate)) {
         curfile($path);
      }
   }
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($old_path) {
   ++$filecount;
   my $old_name  = get_name_from_path($old_path);
   my $old_dir   = get_dir_from_path ($old_path);
   my $old_pref  = get_prefix        ($old_name);
   my $new_suff  = get_correct_suffix($old_path);

   # If new suffix is '.unk', increment $unkncount, otherwise increment $typecount:
   $new_suff eq '.unk' and ++$unkncount or ++$typecount;

   # Make new name and path:
   my $new_name = $old_pref . $new_suff;
   my $new_path = path($old_dir, $new_name);

   # Increment "same" counter if new name is same as old name, else increment "different" counter:
   $new_name eq $old_name and ++$samecount or  ++$diffcount;

   # If debugging, print values of various variables:
   if ($Debug) {
      say STDERR '';
      say STDERR "In \"get-suffixes.pl\", in curfile, after setting variables.";
      say STDERR "\$filecount = \"$filecount\".";
      say STDERR "\$old_path  = \"$old_path\".";
      say STDERR "\$old_dir   = \"$old_dir\".";
      say STDERR "\$old_name  = \"$old_name\".";
      say STDERR "\$old_pref  = \"$old_pref\".";
      say STDERR "\$new_suff  = \"$new_suff\".";
      say STDERR "\$new_name  = \"$new_name\".";
      say STDERR "\$new_path  = \"$new_path\".";
      say STDERR "old and new names are SAME"      if $new_name eq $old_name;
      say STDERR "old and new names are DIFFERENT" if $new_name ne $old_name;
      say STDERR '';
   }

   # If new name is same as old name, announce that old name is correct and return 1:
   if ( $new_name eq $old_name ) {
      say STDOUT "Correct:   \"$old_name\"";
      return 1;
   }

   # Otherwise, announce that old name is incorrect but DON'T attempt to rename anything:
   else {
      say STDOUT "Incorrect: \"$old_name\" => \"$new_name\"";
      # If we were SETTING suffixes,
      # instead of GETTING suffixes,
      # we would have code here
      # for renaming files.
      # But we aren't,
      # so we don't.
      return 1;
   }

   # We can't possibly get here.
   # But if we do, something truly bizarre has happened,
   # so print some cryptic shit and return 666:

   print ((<<'   666') =~ s/^   //gmr);

   Back, he spurred like a madman, shrieking a curse to the sky,
   With the white road smoking behind him and his rapier brandished high.
   Blood red were his spurs in the golden noon; wine-red was his velvet coat;
   When they shot him down on the highway,
           Down like a dog on the highway,
   And he lay in his blood on the highway, with a bunch of lace at his throat.
   666

   return 666;
} # end sub curfile

# Print statistics:
sub stats {
   say STDERR '';
   say STDERR "Stats for \"get-suffixes.pl\":";
   say STDERR "Navigated $direcount directories.";
   say STDERR "Encountered $filecount files.";
   say STDERR "Found $typecount files of known type.";
   say STDERR "Found $unkncount files of unknown type.";
   say STDERR "Found $samecount files with correct suffix.";
   say STDERR "Found $diffcount files with  wrong  suffix.";


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

   Welcome to "get-suffixes.pl", Robbie Hatley's nifty file name extension
   getter. This program determines the types of the files in the current directory
   (and all subdirectories if a -r or --recurse option is used) then displays the
   original file names, then, if the original suffix was incorrect, it also gets
   and displays the file's name with the correct suffix. For example, if a file
   is named "cat.txt", but the file is actually a jpg file, this program will
   display the new file name as "cat.jpg".

   Note that this program DOESN'T alter the names of files. To set correct
   file-name suffixes, use my program "set-suffixes.pl" instead.

   -------------------------------------------------------------------------------
   Command lines:

   get-extensions.pl [-h|--help]            (to print this help and exit)
   get-extensions.pl [options] [argument]   (to get file-name extensions)

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

   (Exception: Technically, you can use an integer as a boolean, and it doesn't
   need quotes or parentheses; but if you use an integer, any non-zero integer
   will process all paths and 0 will process no paths, so this isn't very useful.)

   Arguments and options may be freely mixed, but the arguments must appear in
   the order Arg1, Arg2 (RegExp first, then File-Type Predicate); if you get them
   backwards, they won't do what you want, as most predicates aren't valid regexps
   and vice-versa.

   A number of arguments greater than 2 will cause this program to print an error
   message and abort.

   Happy suffix getting!

   Cheers,
   Robbie Hatley,
   Programmer.
   END_OF_HELP
   return 1;
} # end sub help
