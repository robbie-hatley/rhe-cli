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
use List::Util      qw( any                         );
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
my @Sha1      = ()        ; # SHA-1 hashes.             hashes    (empty)
my $Cwd       = ''        ; # Share cwd between subs.   cwd       blank

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire().
my $filecount = 0 ; # Count of non-meta data files encountered.
my $newfcount = 0 ; # Count of new ".sha1" files created.
my $updfcount = 0 ; # Count of old ".sha1" files updated.
my $findcount = 0 ; # Count of files found matching our desired SHA-1.

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

   # Interpret the elements of @Args as being SHA-1 hashes:
   @Sha1 = @Args;

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Increment directory counter:
   ++$direcount;

   # Get current working directory:
   $Cwd = d getcwd;

   # Announce current working directory if being verbose:
   if ( 2 == $Verbose) {
      say STDERR "\nDirectory # $direcount: $Cwd\n";
   }

   # ======= MAKE SURE THAT THIS DIRECTORY'S ".sha1" FILE IS UP-TO-DATE: =====================================

   # Make a hash table to hold SHA-1 file hashes of all non-meta data files in this directory:
   my %ht;

   # Does ".sha1" not exist in this directory?
   my $new_flag = !(-e e ".sha1");
   $new_flag and ++$newfcount;

   # If ".sha1" exists, read its contents into our hash table:
   if (!$new_flag) {
      my $sha1fh = undef;
      open($sha1fh, '<', e '.sha1')
      or say STDERR "Error: Couldn't open file \".sha1\" in directory \"$Cwd\"."
      and return 0;
      while (<$sha1fh>) {
         chomp;
         my ($name, $size, $mod, $sha1) = split '/', $_ ;
         $ht{$name} = [$size, $mod, $sha1];
      }
      close($sha1fh)
      or say STDERR "Error: Couldn't close file \".sha1\" in directory \"$Cwd\"."
      and return 0;
   }

   # Get a list of all entries in current directory:
   my @entries;
   my $dh = undef;
   opendir($dh, e $Cwd)          or say STDERR "Error: Couldn't open  directory \"$Cwd\"." and return 0;
   while (readdir($dh)) {
      chomp;
      my $entry = d $_ ;
      next if !is_data_file($entry);
      next if  is_meta_file($entry);
      push @entries, $entry;
      ++$filecount;
   }
   closedir $dh                  or say STDERR "Error: Couldn't close directory \"$Cwd\"." and return 0;

   # Have we updated the hash table?
   my $update_flag = 0;

   # Make sure every directory entry exists in hash table:
   foreach my $entry (@entries) {
      my @stats = lstat e $entry;
      my $size  = $stats[7];
      my $mod   = $stats[9];
      if ( ! defined $ht{$entry} || $size != $ht{$entry}->[0] || $mod != $ht{$entry}->[1] ) {
         if ($Debug) {say STDERR "directory entry \"$entry\" is not in hash table";}
         my $hash = sha1($entry);
         $ht{$entry} = [$size, $mod, $hash];
         $update_flag = 1;
      }
   }

   # Delete hash-table entries which don't exist in directory:
   foreach my $key (keys %ht) {
      if ( ! any { $_ eq $key } @entries ) {
         if ($Debug) {say STDERR "hash-table key \"$key\" is not in directory";}
         delete $ht{$key};
         $update_flag = 1;
      }
   }

   # If ".sha1" exists and we altered the hash table, increment update counter:
   !$new_flag && $update_flag and ++$updfcount;

   # If ".sha1" exists and needs to be overwritten, unlike it first:
   if ( !$new_flag && $update_flag ) {unlink e '.sha1';}

   # If we need to update file hashes, write hash table to ".sha1":
   if ($new_flag || $update_flag) {
      my $sha1fh = undef;
      open($sha1fh, '>', e '.sha1')
      or say STDERR "Error: Couldn't open file \".sha1\" for writing in directory \"$Cwd\"."
      and return 0;
      foreach my $entry (keys %ht) {
         say $sha1fh join('/', $entry, $ht{$entry}->[0], $ht{$entry}->[1], $ht{$entry}->[2]);
      }
      close($sha1fh)
      or say STDERR "Error: Couldn't close file \".sha1\" in directory \"$Cwd\"."
      and return 0;
   }

   # ======= SEARCH FOR FILE MATCHING GIVEN SHA1 HASHES: =====================================================

   # For each hash in @Sha1 iterate through the key/value pairs of %ht, looking for our desired SHA-1;
   # if the SHA-1 for a key matches the SHA-1 we're looking for, increment find counter and print path:
   foreach my $sha1 (@Sha1) {
      foreach my $key (keys %ht) {
         if ( $ht{$key}->[2] eq $Sha1 ) {
            ++$filecount;
            say STDOUT path($Cwd, $key);
         }
      }
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
      say    STDERR "Processed $filecount files.";
      say    STDERR "Created $newfcount new \".sha1\" files.";
      say    STDERR "Updated $updfcount old \".sha1\" files.";
      say    STDERR "Found $findcount files matching SHA-1 hash \"$Sha1\".";
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
   --recurse option is used) which match the given hash. In the process, this
   program will create or update a file of SHA-1 hashes called ".sha" in every
   directory it processes, and it will use the information in that file to search
   for files in that directory for every subsequent search. (See also my program
   "sha1.pl" which updates ".sha1" files, locally or recursively.)

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

   All non-option arguments will be interpreted as SHA-1 hashes to look for.
   For example, say an online database mentions a photo of a green island with
   this SHA-1 hash:

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
