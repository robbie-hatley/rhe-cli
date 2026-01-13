#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# sha1.pl
# Creates or updates database ".sha1tree" of SHA1 hashes of files in current directory tree.
# Written by Robbie Hatley.
# Edit history:
# Fri Jan 09, 2026: Wrote it.
# Sat Jan 10, 2026: Got rid of unnecessary "use" statements; explained what each remaining "use" is for.
##############################################################################################################

use v5.36;              # To get "signatures" feature.
use utf8::all;          # Dramatically simplifies handing Unicode and UTF-8, except for cwd.
use Cwd::utf8;          # Also makes cwd handle Unicode and UTF-8 correctly.
use Time::HiRes 'time'; # For benchmarking.
use RH::Dir;            # Gives "RecurseDirs", "glob_regexp_utf8", "is_data_file", "is_meta_file", and "sha1".

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
my $Verbose   = 0         ; # Be verbose?               0,1,2     Be quiet.
my $OriDir    = cwd       ; # Original directory.       dir       The directory we started in.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire().
my $filecount = 0 ; # Count of data files processed.

# Hash table of SHA1 hashes of files in this tree:
my %ht;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv     ; # Process @ARGV.
sub sha1tree ; # Update file ".sha1tree" and return hash table of all paths hashed.
sub curdire  ; # Process current directory.
sub curfile  ; # Process current file.
sub stats    ; # Print statistics.
sub help     ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Start execution timer:
   my $t0 = time;
   my @s0 = localtime($t0);

   # Process @ARGV and set settings:
   argv;

   # Print program entry message if being terse or verbose:
   if ( $Verbose >= 1 ) {
      printf STDERR "Now entering program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n",
      $s0[2], $s0[1], $s0[0], 1+$s0[4], $s0[3], 1900+$s0[5];
      say STDERR "Top-level directory = $OriDir";
   }

   # Print compilation time and variables: if being verbose:
   if ( $Verbose >= 2 ) {
      printf STDERR "Compilation time was %.3fms\n",
      1000 * ($cmpl_end - $cmpl_beg);
      say STDERR 'Values of variables after processing @ARGV:';
      say STDERR "pname     = $pname";
      say STDERR "cmpl_beg  = $cmpl_beg";
      say STDERR "cmpl_end  = $cmpl_end";
      say STDERR "Options   = (@Opts)";
      say STDERR "Arguments = (@Args)";
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR "Verbose   = $Verbose";
      say STDERR "OriDir    = $OriDir";
      say STDERR '';
   }

   # If user requested help, just print help:
   if ($Help) {
      help;
   }

   # Otherwise, process current directory tree:
   else {
      # Gather files hashes from all subdirectories:
      RecurseDirs {curdire};

      # If debugging, say number of files hashed by "RecurseDirs {curdire}":
      if ($Debug) {say STDERR "Debug msg in main, in dir \"$OriDir\": hashed $filecount files.\n"}

      # Write %ht to '.sha1tree':
      my $fh = undef;
      open($fh, '>', '.sha1tree')
      or die "Error: Couldn't open file \".sha1tree\" for writing in directory \"$OriDir\".\n$!\n";
      foreach my $path (sort {$a cmp $b} keys %ht) {
         my $size = $ht{$path}->{Size};
         my $modt = $ht{$path}->{Modt};
         my $sha1 = $ht{$path}->{Sha1};
         my $string = join "\0", $path, $size, $modt, $sha1;
         print {$fh} $string, "\0\0";
      }
      close($fh)
      or die "Error: Couldn't close file \".sha1\" in directory \"$OriDir\".\n$!\n";

      # Announce writing file:
      say "\nWrote \".sha1tree\" file to directory \"$OriDir\".";

      # Print stats:
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
   for ( @ARGV ) {           # For each element of @ARGV,
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
   }

   # (This program cheerfully ignores all arguments.)

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Increment directory counter:
   ++$direcount;

   # Get current working directory:
   my $cwd = cwd;

   # Get a sorted list of paths of all non-meta data files in current directory:
   my @paths = glob_regexp_utf8($cwd, 'F');

   # For each path which is a non-meta data file, send it to curfile:
   foreach my $path (@paths) {
      next if !is_data_file($path);
      next if  is_meta_file($path);
      curfile($path);
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Record each path sent from curdire in %ht:
sub curfile ($path) {
   # Increment file counter:
   ++$filecount;

   # Associate a file-info hash (containing the size, mod time, and hex SHA-1 hash of the data in this file)
   # to the file's path in %ht:
   my @stats  = lstat $path;
   my $size   = $stats[7];
   my $modt   = $stats[9];
   my $sha1   = sha1 $path;
   $ht{$path} = {Size => $size, Modt => $modt, Sha1 => $sha1};
}

# Print statistics for this program run:
sub stats {
   # If being terse or verbose, print basic stats to STDERR:
   if ( $Verbose >= 1 ) {
      say STDERR '';
      say STDERR "Statistics for running script \"$pname\" on \"$OriDir\" directory tree:";
      say STDERR "Navigated $direcount directories.";
      say STDERR "Found and hashed $filecount non-empty non-meta data files.";
   }

   return 1;
} # end sub stats

# Print help:
sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "sha1.pl". This program creates or updates a database ".sha1" of
   SHA1 hashes of all non-meta data files in current directory (and all of its
   subdirectories if a "-r" or "--recurse" option is used).

   -------------------------------------------------------------------------------
   Command lines:

   sha1.pl -h | --help   (to print this help and exit)
   sha1.pl [options]     (to maintain ".sha1" databases)

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
   For example, use -vr to verbosely and recursively update SHA-1 databases.

   If two piled-together single-letter options conflict, the option
   appearing lowest on the options chart above will prevail.
   If two separate (not piled-together) options conflict, the right
   overrides the left.

   If you want to use an argument that looks like an option, use a "--" option;
   that will force all command-line entries to its right to be considered
   "arguments" rather than "options". (Caveat: as of 2025-04-10, this program
   ignores all arguments. This, however, may change, if I find a use for them.)

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   As of 2025-04-10, this program ignores all arguments. This, however, may
   change, if I find a use for them.


   Happy file hashing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
