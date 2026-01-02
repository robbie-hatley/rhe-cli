#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# sha2gib.pl
# Converts SHA1 file names to gibberish.
# Written by Robbie Hatley.
# Edit history:
# Fri Jan 02, 2026: Wrote it.
##############################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes qw( time );

use Scalar::Util qw( looks_like_number reftype );
use Regexp::Common;
use Unicode::Normalize;
use Unicode::Collate;
use MIME::QuotedPrint;

use RH::Dir;        # Recurse directories; get list of file-info packets for names matching a regexp; etc.
use RH::Util;       # Unbuffered single-keystroke inputs; etc.

# ======= VARIABLES: =========================================================================================

# ------- System Variables: ----------------------------------------------------------------------------------

$" = ', ' ; # Quoted-array element separator = ", ".

# ------- Global Variables: ----------------------------------------------------------------------------------

# WARNING: Do NOT initialize global variables on their declaration line! That wipes-out changes made to them
#          by BEGIN, UNITCHECK, CHECK, and INIT blocks! Instead, initialize them in those blocks.
our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.
our    $cmpl_beg;                              # Declare compilation begin time.
BEGIN {$cmpl_beg = time}                       # Set     compilation begin time.
our    $cmpl_end;                              # Declare compilation end   time.
INIT  {$cmpl_end = time}                       # Set     compilation end   time.

# NOTE: Always remember, if using BEGIN blocks, only the declaration half of any "my|our $varname = value;"
# statement is executed before the begin blocks; the "= value;" part is executed AFTER all BEGIN blocks!!!
# So, THIS code:
#    my $dog = 'Spot';
#    BEGIN {defined $dog ? print("defined\n") : print("undefined\n");}
#    print("My dog's name is $dog.\n");
#    END   {print("$dog is a nice dog.\n");}
# Is the same as THIS code:
#    my $dog;
#    defined $dog ? print("defined\n") : print("undefined\n");
#    $dog = 'Spot';
#    print("My dog's name is $dog.\n");
#    print("$dog is a nice dog.\n");
# And EITHER of those code blocks will print:
#    undefined
#    My dog's name is Spot.
#    Spot is a nice dog.

# ------- Local variables: -----------------------------------------------------------------------------------

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 1         ; # Be verbose?               0,1,2     Be terse.
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
# NOTE: There is no "$Target"    because this program renames regular files with SHA1 names only.
# NOTE: There is no "$RegExp"    because this program renames regular files with SHA1 names only.
# NOTE: There is no "$Predicate" because this program renames regular files with SHA1 names only.
my $OriDir    = cwd       ; # Original directory.       cwd       Directory on program entry.

# SHA1 pattern:
my $ShaPat = qr(^[0-9a-f]{40}(?:-\(\d{4}\))?(?:\.\w+)?$);

# Counters:
my $direcount = 0         ; # Count of directories processed by curdire().
my $filecount = 0         ; # Count of files       processed by curfile().
my $nonacount = 0         ; # Count of all files for which a gibberish name could not be found.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

# NOTE: These alert the compiler that these names, when encountered (whether in subroutine definitions,
# BEGIN, CHECK, UNITCHECK, INIT, END, other subroutines, or in the main body of the program), are subroutines,
# so it needs to find, compile, and link their definitions:
sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub BLAT    ; # Print messages only if debugging.
sub stats   ; # Print statistics.
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
      say STDERR '';
   }

   # If debugging, print the values of all variables except counters, after processing @ARGV:
   if ( $Debug >= 1 ) {
      say STDERR 'Debug: Values of variables after processing @ARGV:';
      say STDERR "pname     = $pname";
      say STDERR "cmpl_beg  = $cmpl_beg";
      say STDERR "cmpl_end  = $cmpl_end";
      say STDERR "Options   = (@Opts)";
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR "Verbose   = $Verbose";
      say STDERR "OriDir    = $OriDir";
      say STDERR "Recurse   = $Recurse";
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
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0  ;
      /^-$s*t/ || /^--terse$/   and $Verbose =  1  ; # Default.
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2  ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0  ; # Default.
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1  ;
      # NOTE: $Target is always 'F', as only regular files can have SHA1 hashes.
   }

   # Get number of arguments:
   my $NA = scalar(@Args);

   # Ignore all arguments:
   if ( $NA > 0 ) {warn "Warning: Ignoring argument(s).\n"}

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

   # Get sorted list of paths in $cwd matching 'F' and $ShaPat:
   my @paths = sort {$a cmp $b} glob_regexp_utf8($cwd, 'F', $ShaPat);

   # Send each path to curfile():
   foreach my $path (@paths) {curfile($path)}

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($path) {
   # Increment file counter:
   ++$filecount;

   # Get name, dire, and suffix from path:
   my $name   = get_name_from_path($path);
   my $dire   = get_dir_from_path($path);
   my $suffix = get_suffix($name);

   # Try to find a random file name that doesn't already exist in file's directory:
   my $new_name = find_avail_rand_name($dire, '', $suffix);
   $Db and say STDERR "In curfile(). \$new_name = $new_name";

   # Check to see if find_avail_rand_name returned an error code:
   '***ERROR***' eq $new_name
   and ++$nonacount
   and say STDOUT "Error: unable to find available gibberrish name for \"$name\"."
   and return 0;

   # If debugging or simulating, just go through the motions then return 1:
   $Db || $Simulate
   and ++$simucount and say STDOUT "Simulated Rename: $name => $new_name" and return 1;

   # Otherwise, attempt rename:
   rename_file($name, $new_name)
   and ++$renacount and say STDOUT "Renamed: $name => $new_name" and return 1
   or  ++$failcount and say STDOUT "Failed:  $name => $new_name" and return 0;

   # Return success code 1 to caller:
   return 1;
} # end sub curfile

# Print messages only if debugging:
sub BLAT ($string) {if ($Debug) {say STDERR $string}}

# Print statistics for this program run:
sub stats {
   # If being terse or verbose, print basic stats to STDERR:
   if ( $Verbose >= 1 ) {
      say STDERR '';
      say STDERR "Statistics for running script \"$pname\" on \"$OriDir\" directory tree";
      say STDERR "with target \"$Target\", regexp \"$RegExp\", and predicate \"$Predicate\":";
      say STDERR "Navigated $direcount directories.";
      say STDERR "Processed $filecount files matching given target, regexp, and predicate.";
   }
   return 1;
} # end sub stats

# Print help:
sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "$pname". This program renames any files in the current directory
   (and all subdirectories if a -r or --recurse option is used) which have SHA1
   names to gibberish names.

   -------------------------------------------------------------------------------
   Command lines:

   $pname -h | --help   (to print this help and exit)
   $pname [options]     (to rename SHA1 file names to gibberish names)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.
   -e or --debug      Print diagnostics.
   -q or --quiet      Be quiet.
   -t or --terse      Be terse.                         (DEFAULT)
   -v or --verbose    Be verbose.
   -l or --local      DON'T recurse subdirectories.     (DEFAULT)
   -r or --recurse    DO    recurse subdirectories.
   --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively process items.

   If multiple conflicting separate options are given, latter overrides former.

   If multiple conflicting single-letter options are piled after a single hyphen,
   the precedence is the inverse of the options in the above table.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   "$pname" ignores all arguments.


   Happy SHA1-to-giberish file renaming!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
