#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# repair-directory-dates.pl
# Repairs the dates on directories which have been "bumped" by "repair-dolphin-directory-files.pl" (or other
# program that creates, removes, or alters hidden files in directories) by setting the directory dates to the
# date of the most-recent non-hidden file in the directory.
# Written by Robbie Hatley.
# Edit history:
# Sat Mar 23, 2024: Wrote it.
# Thu Aug 15, 2024: -C63; got rid of unnecessary "use" statements.
# Wed Mar 12, 2025: Now using BEGIN and INIT blocks and global vars for pname, cmpl_beg, cmpl_end.
#                   No-longer announces directories on entry, but now does announce successful and failed
#                   directory rename attempts. stats() now prints totals of successful and failed renames.
##############################################################################################################

use v5.36;
use utf8;

use Cwd          qw( cwd getcwd );
use Time::HiRes  qw( time       );

use RH::Dir;
use RH::Util;

# ======= GLOBAL VARIABLES: ==================================================================================

our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.
our    $cmpl_beg;                              # Declare compilation begin time.
BEGIN {$cmpl_beg = time}                       # Set     compilation begin time.
our    $cmpl_end;                              # Declare compilation end   time.
INIT  {$cmpl_end = time}                       # Set     compilation end   time.

# ======= LEXICAL VARIABLES: =================================================================================

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 0         ; # Be verbose?               bool      Shhhh!! Be quiet!!
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire.
my $filecount = 0 ; # Count of files processed by curdire loop.
my $hidncount = 0 ; # Count of hidden files.
my $opencount = 0 ; # Count of non-hidden files.
my $datecount = 0 ; # Count of dates set.
my $failcount = 0 ; # Count of failed attempts to set dates.

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

   # Process @ARGV and set settings:
   argv;

   # Print program entry message if being verbose:
   if ( 2 == $Verbose ) {
      say STDERR "\nNow entering program \"$pname\" at timestamp $t0.";
      printf(STDERR "Compilation took %.3fms\n",1000*($cmpl_end-$cmpl_beg));
   }

   # Print the values of all 6 settings variables if debugging:
   if ( 1 == $Debug ) {
      say STDERR '';
      say STDERR "Options   = (@Opts)";
      say STDERR "Arguments = (@Args)";
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR "Verbose   = $Verbose";
      say STDERR "Recurse   = $Recurse";
   }

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   $Help and help or ($Recurse and RecurseDirs {curdire} or curdire) and stats;

   # Stop execution timer:
   my $t1 = time;

   # Print exit message if being verbose:
   if ( 2 == $Verbose ) {
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

   # (Non-option arguments are ignored.)

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Increment directory counter:
   ++$direcount;

   # Get current working directory:
   my $cwd = d getcwd;

   # Try to open, read, and close $cwd; if any of those operations fail, die:
   my $dh = undef;
   opendir $dh, e $cwd
   or die "Fatal error: Couldn't open  directory \"$cwd\".\n$!\n";

   my @names = sort {$a cmp $b} d(readdir($dh));
   scalar(@names) >= 2 # $dir should contain at least '.' and '..'!
   or die "Fatal error: Couldn't read  directory \"$cwd\".\n$!\n";

   closedir $dh
   or die "Fatal Error: Couldn't close directory \"$cwd\".\n$!\n";

   # Set the time stamp of the current working directory to the time stamp
   # of the most-recently-modified of the non-hidden files present:
   my $max_Mtime = 0;
   foreach my $name (@names) {
      next if '.'  eq $name;
      next if '..' eq $name;
      ++$filecount;
      # Don't base cwd's date on hidden files:
      if ( '.' eq substr($name, 0, 1) ) {++$hidncount;next;}
      ++$opencount;
      my @stats = lstat e $name;
      if ( scalar(@stats) < 13 ) {
         warn "Warning: Can't lstat \"$name\" in \"$cwd\".\n";
         next;
      }
      if ( $stats[9] > $max_Mtime ) { $max_Mtime = $stats[9] }
   }
   utime $max_Mtime, $max_Mtime, e($cwd)
   and say STDOUT "Set date on directory \"$cwd\"."
   and ++$datecount
   or  say STDOUT "Error: couldn't set date on directory \"$cwd\"."
   and ++$failcount;

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Print statistics for this program run, if being terse or verbose:
sub stats {
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say STDERR '';
      say STDERR 'Statistics for this directory tree:';
      say STDERR "Navigated $direcount directories.";
      say STDERR "Found $hidncount hidden files.";
      say STDERR "Found $opencount non-hidden files.";
      say STDERR "Set $datecount directory dates.";
      say STDERR "Failed $failcount date-set attempts.";
   }
   return 1;
} # end sub stats

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "repair-directory-dates.pl". This program sets the mod date of the
   current working directory (and all of its subdirectories if a -r or --recurse
   option is used) to the mod date of the most-recently-modified non-hidden item
   within.

   -------------------------------------------------------------------------------
   Command lines:

   repair-directory-dates.pl -h | --help     (to print this help and exit)
   repair-directory-dates.pl [options]       (to set directory dates)

   -------------------------------------------------------------------------------
   Description of options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -n or --ndebug     DON'T print diagnostics.        (DEFAULT)
   -e or --debug      Print diagnostics.
   -q or --quiet      Be quiet.
   -t or --terse      Be terse.                       (DEFAULT)
   -v or --verbose    Be verbose.
   -l or --local      DON'T recurse subdirectories.   (DEFAULT)
   -r or --recurse    DO    recurse subdirectories.

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -qr to quietly and recursively process items.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: herlvtq.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above, and all non-option arguments, are ignored.

   Happy directory dating!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
__END__
