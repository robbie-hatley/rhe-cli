#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# gib-to-sha1.pl
# Renames each file in the current directory (and all subdirectories if a -r or --recurse option is used)
# which has a 8-lower-case-letter "gibberish" file name to a name consisting of the sha1 hash of
# the data in the file followed by the original file name extension.
#
# Edit history:
# Wed Nov 11, 2020: Wrote it. (Converts gibberish names to sha1 names only.)
# Mon Dec 21, 2020: Now also has recursion available.
# Sun Jan 03, 2021: Now also processes many other file types besides just jpg.
# Mon Feb 15, 2021: Split into "gib-to-sha1.pl" and "wsl-to-sha1.pl". "gib-to-sha1.pl" now handles gib only,
#                   with no extension discrimination.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Thu Oct 03, 2024: Got rid of Sys::Binmode and common::sense; added "use utf8".
# Mon Mar 17, 2025: Shebang to "-C63". Reduced width from 120 to 110. Increased min ver from "5.32" to "5.36".
#                   Shortened sub names. Got rid of prototypes. Added signature to curfile().
##############################################################################################################

use v5.36;
use utf8;

use Cwd          qw( cwd getcwd );
use Time::HiRes  qw( time       );
use List::Util   qw( all        );

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

# Gibberish file-name pattern:
my $Gib = qr/^[a-z]{8}(?:-\(\d{4}\))?(?:\.[\pL\pN]+)?$/o;

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 0         ; # Be verbose?               bool      Shhhh!! Be quiet!!
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
# No "$Target" variable because it doesn't make sense to get the SHA1 data hash of a non-data object.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.

# Counters:
my $direcount = 0; # Count of directories navigated.
my $filecount = 0; # Count of non-meta paths matching target and regexp.
my $predcount = 0; # Count of paths also matching $Predicate.
my $renacount = 0; # Count of files successfully renamed.
my $failcount = 0; # Count of failed file-rename attempts.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
sub help    ; # Print help.

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

      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
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

# Process @ARGV :
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
      $RegExp = qr/$Args[0]/o;   # set $RegExp to $Args[0].
   }

   # Second argument, if present, is a file-selection predicate:
   if ( $NA > 1 ) {              # If number of arguments >= 2,
      $Predicate = $Args[1];     # set $Predicate to $Args[1].
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Increment directory counter:
   ++$direcount;

   # Get and announce current working directory:
   my $curdir = cwd_utf8;
   say "\nDir # $direcount: $curdir\n";

   # Get a list of all paths in current directory matching target "F", regexp $Gib, and regexp $RegExp:
   my @paths = glob_regexp_utf8($curdir, 'F', $RegExp);
   #say for @paths; exit;
   # Send each matching path to curfile:
   foreach my $path (@paths) {
      # Bypass all files that don't have gibberish names:
      my $name = get_name_from_path($path);next if $name !~ m/$Gib/;
      # Bypass all non-data files (dirs, links, pipes, sockets, etc):
      next if !is_data_file($path);
      # Bypass all meta files (hidden, settings, metadata, etc):
      next if is_meta_file($path);
      # Count all non-meta data files matching regexps "$Gib" and "$RegExp":
      ++$filecount;
      # Skip all paths not matching $Predicate:
      local $_ = e $path;
      next if !eval($Predicate);
      # If we get to here, increment $predcount and send path to curfile:
      ++$predcount;
      curfile($path);
   }
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($path) {
   my $oldname = get_name_from_path($path);

   my $newname = hash($path, 'sha1', 'name');
   '***ERROR***' eq $newname and say "Couldn't find available rand name for $path" and return 0;
   rename_file($oldname, $newname)
   and ++$renacount
   and say "Renamed \"$oldname\" to \"$newname\"."
   and return 1
   or  ++$failcount
   and warn "Failed to rename \"$oldname\" to \"$newname\".\n"
   and return 0;
} # end sub curfile

# Print stats:
sub stats {
   print("\nStats for program \"pname\":\n");
   printf("Navigated %6u directories.\n",                                                         $direcount);
   printf("Found     %6u non-meta data files with gibberish names matching regexp \"$RegExp\".\n",$filecount);
   printf("Found     %6u such files also matching predicate \"$Predicate\".\n",                   $predcount);
   printf("Renamed   %6u files.\n",                                                               $renacount);
   printf("Failed    %6u file-rename attempts.\n",                                                $failcount);
   return 1;
} # end sub stats

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "gib-to-sha1.pl". This program renames all non-meta data files in
   the current directory (and all subdirectories if a -r or --recurse option is
   used) which have 8-lower-case-letter "gibberish" file names to names consisting
   of the SHA-1 hash of the data in the file followed by the file name extension
   of the original file.

   Command line:
   gib-to-sha1.pl [options]

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.
   "-r" or "--recurse"          Recurse subdirectories.

   This program recognizes no other options and takes no arguments.
   All arguments and non-listed options will be ignored.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
