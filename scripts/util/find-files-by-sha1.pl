#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# find-files-by-sha1.pl
# Files data files matching a given SHA1 hash.
# Written by Robbie Hatley.
# Edit history:
# Sat Mar 22, 2025: Wrote it.
##############################################################################################################

# Pragmas:
use v5.36;
use utf8;

# CPAN modules:
use Cwd             qw( cwd getcwd                  );
use Time::HiRes     qw( time                        );
use Scalar::Util    qw( looks_like_number reftype   );
use List::AllUtils  qw( :DEFAULT                    );
use Digest::SHA     qw( sha1_hex                    );

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
my $Verbose   = 0         ; # Be verbose?               0,1,2     Be quiet.
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $Sha1      = ''        ; # SHA-1 hash of a file      hash      blank

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire().
my $filecount = 0 ; # Count of data files matching given SHA-1.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub sha1    ; # SHA-1 hash of a file.
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
      say STDERR "Sha1      = $Sha1";
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

# Process @ARGV and set settings:
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

   # If user typed other-than-1 arguments, and we're not debugging or getting help,
   # print error and help messages and exit:
   if ( 1 != $NA                 # If number of arguments is other-than-1,
        && !$Debug && !$Help ) { # and we're not debugging and not getting help,
      error($NA);                # print error message,
      help;                      # and print help message,
      exit 666;                  # and exit, returning The Number Of The Beast.
   }

   # First argument, if present, is SHA-1 hash to look for:
   if ( $NA >= 1 ) {             # If we have at-least-1 arguments,
      $Sha1 = $Args[0];          # set $Sha1 to $Args[0].
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

   # Announce current working directory if being verbose:
   if ( 2 == $Verbose) {
      say STDERR "\nDirectory # $direcount: $cwd\n";
   }

   # Get list of all entries in current directory:
   my $dh = undef;
   opendir($dh, $cwd) or say STDERR "Error: Couldn't open directory \"$cwd\"." and return 0;
   my @entries = readdir($dh);
   closedir $dh;

   # Process entries:
   foreach my $entry (sort @entries) {
      next if ! -e e $entry;
      my @stats = lstat e $entry;
      next if ! -f _ ; # Skip "not a file" files
      next if   -d _ ; # Skip directories
      next if   -l _ ; # Skip links
      next if   -p _ ; # Skip pipes
      next if   -S _ ; # Skip sockets
      next if   -b _ ; # Skip block     special files
      next if   -c _ ; # Skip character special files
      next if   -t _ ; # Skip TTYs
      next if   -z _ ; # Skip empty files
      # If we get to here, we have a hashable data file, so get its hash:
      my $hash = sha1($entry);
      if ($Debug) {
         say STDERR "In \"for each entry\" loop in curdire.";
         say STDERR "Entry name = \"$entry\".";
         say STDERR "Entry hash = \"$hash\".";
         say STDERR "Refer hash = \"$Sha1\".";
      }
      next if '***ERROR***' eq $hash;
      # Skip this file if it doesn't match the hash the user is searching for:
      next if $hash ne $Sha1;
      # If we get to here we found a match, so increment file counter and print path:
      ++$filecount;
      say path($cwd, $entry);
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Return the SHA-1 hash of a named file in current directory:
sub sha1 ($name) {
   my   $fh = undef;                           # File handle (initially undefined).
   local $/ = undef;                           # Set "input record separator" to EOF.
   open($fh, '< :raw', e $name)                # Try to open the file for reading in "raw" mode.
   or warn "Error: couldn't open \"$name\".\n" # If file-open failed, warn user
   and return '***ERROR***';                   # and return error code.
   my $data = <$fh>;                           # Slurp file into $data as one big string of unprocessed bytes.
   defined $data                               # Test if $data is defined.
   or warn "Error: couldn't read \"$name\".\n" # If file-read failed, warn user
   and return '***ERROR***';                   # and return error code.
   close($fh);                                 # Close file.
   return sha1_hex($data);                     # Return SHA-1 hash of file.
} # end sub sha1

# Print statistics for this program run:
sub stats {
   # If being terse or verbose, print basic stats to STDERR:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say    STDERR '';
      say    STDERR 'Statistics for this directory tree:';
      say    STDERR "Navigated $direcount directories.";
      say    STDERR "Found $filecount files matching SHA-1 hash \"$Sha1\".";
   }

   return 1;
} # end sub stats

# Handle errors:
sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most one
   argument which, if present, should be a hex SHA-1 hash to search for.
   Help follows.
   END_OF_ERROR
   return 1;
} # end sub error

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "find-files-by-sha1.pl". Given a hex SHA-1 hash, this program
   searches for files in the current directory (and all subdirectories if a -r or
   --recurse option is used) which match the given hash.

   -------------------------------------------------------------------------------
   Command lines:

   find-files-by-sha1.pl -h | --help      (to print this help and exit)
   find-files-by-sha1.pl [options] sha1   (to find files with hash sha1)

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

   If you want to use an argument that looks like an option, use a "--" option;
   that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   In addition to options, this program needs 1 mandatory argument, which must be
   a hex SHA-1 hash using lower-case letters a-f. For example, say an online
   database mentions a photo of a green island with this SHA-1 hash:
   bc70c7af332e7ecc952810eac7394cfeed0d03e7
   Then you could see if it's somewhere in your home directory like this:

      cd ~
      find-files-by-sha1.pl -r 'bc70c7af332e7ecc952810eac7394cfeed0d03e7'

   That goes to your home directory, then searches all of its subdirectories,
   unlimited levels deep, for a file with that SHA-1 hash; if such a file
   exists, this program will print its path, such as, perhaps:
   /home/patrick/scenic-pics/unknown-photo-of-green-island.jpg

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
