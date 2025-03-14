#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# refresh-dolphin-directory-file-dates.pl
# Sets the date stamps within all Dolphin ".directory" display settings files to the current time.
# Written by Robbie Hatley on Sat Mar 23, 2024.
# Edit history:
# Sat Mar 23, 2024: Wrote it.
# Thu Aug 15, 2024: -C63; got rid of unnecessary "use" statements.
# Wed Mar 12, 2025: Now using global vars and BEGIN for pname, cmpl_beg, cmpl_end.
##############################################################################################################

use v5.36;
use utf8;

use Cwd          qw( cwd getcwd );
use Time::HiRes  qw( time       );
use POSIX        qw( strftime );

use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

# ======= GLOBAL VARIABLES: ==================================================================================

our $pname;                                      # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/';}  # Set program name.
our $cmpl_beg;                                   # Declare compilation begin time.
our $cmpl_end;                                   # Declare compilation end   time.
BEGIN {$cmpl_beg = time}                         # Set compilation begin time.
INIT  {$cmpl_end = time}                         # Set compilation end   time.

# ======= LEXICAL VARIABLES: =================================================================================

# Setting:      Default Value:   Meaning of Setting:         Range:     Meaning of Default:
my @Opts      = ()           ; # options                     array      Options.
my @Args      = ()           ; # arguments                   array      Arguments.
my $Debug     = 0            ; # Debug?                      bool       Don't debug.
my $Help      = 0            ; # Just print help and exit?   bool       Don't print-help-and-exit.
my $Verbose   = 1            ; # Be wordy?                   0,1,2      Be quiet.
my $Recurse   = 0            ; # Recurse subdirectories?     bool       Be local.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire.
my $filecount = 0 ; # Count of directory entries processed by curdire loop.
my $dlphcount = 0 ; # Count of Dolphin ".directory" files encountered.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Start timer:
   my $t0 = time;

   # Process @ARGV:
   argv;

   # Print program-entry message if being verbose:
   if ( 2 == $Verbose ) {
      say    STDERR "Now entering program \"$pname\"." ;
      printf STDERR "Compilation took %.3fms.\n", 1000 * ($cmpl_end-$cmpl_beg);
   }

   # Print global settings if debugging:
   if ( 1 == $Debug ) {
      say    STDERR "\@Opts      = (@Opts)";
      say    STDERR "\@Args      = (@Args)";
      say    STDERR "\$Debug     = $Debug";
      say    STDERR "\$Verbose   = $Verbose";
      say    STDERR "\$Recurse   = $Recurse";
   }

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   $Help and help or ($Recurse and RecurseDirs {curdire} or curdire) and stats;

   # Print exit message if being verbose:
   if ( 2 == $Verbose ) {
      say    STDERR '';
      say    STDERR "Now exiting program \"$pname\".";
      printf STDERR "Execution time was %.3fms.", 1000 * (time - $t0);
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

   # Announce current working directory if being verbose:
   if ( 2 == $Verbose ) {
      say "\nDirectory # $direcount: $cwd\n";
   }

   # Try to open, read, and close $cwd; die if any of these fail:
   my $dh = undef;
   opendir $dh, e $cwd or die "Fatal error: Couldn't open  directory \"$cwd\".\n$!\n";
   my @names = d(readdir($dh));
   scalar(@names) >= 2 or die "Fatal error: Couldn't read  directory \"$cwd\".\n$!\n";
   closedir $dh or die "Fatal Error: Couldn't close directory \"$cwd\".\n$!\n";
   $filecount += scalar(@names);

   # Set the time stamp of the ".directory" file (if any) in this directory to current time:
   my $dlph = 0; # We haven't found any local ".directory" file yet.
   foreach my $name (@names) {
      next if '.directory' ne $name;
      # If we get to here, file ".directory" exists in this directory:
      $dlph = 1;    # We found a local ".directory" file.
      ++$dlphcount; # Increment the global ".directory" file counter.
      last;
   }

   # Return 1 (indicating "success" to RecurseDirs) if no Dolphin file was found in this directory
   # (but don't print any warnings,as it's quite normal for many directories to not have a ".directory" file):
   if (!$dlph) {
      return 1;
   }

   # Try to open ".directory" file; warn user and return if we fail:
   my $dfh = undef;
   if (!open $dfh, '+<', '.directory') {
      warn "Couldn't open \".directory\" file in directory \"$cwd\".\n";
      return 1;
   }

   # Get the lines of the ".directory" file:
   my @lines = <$dfh>;

   # Make a time stamp at the current time:
   my @LocalTimeFields = localtime(time);
   my $TimeStamp = strftime('%Y,%m,%d,%H,%M,%S', @LocalTimeFields);

   # Write the time stamp to the appropriate line of @lines:
   for ( my $i = 0 ; $i <= $#lines ; ++$i ) {
      next if $lines[$i] !~ m/^Timestamp=/;
      $lines[$i] =~ s/^(Timestamp=).+$/${1}$TimeStamp/;
      last;
   }

   # Overwrite ".directory" with @lines:
   seek  $dfh, 0, 0;
   print $dfh $_ for @lines;
   close $dfh;

   # State what we've done to STDOUT:
   printf STDOUT "Time stamp set to \"%s\" in \"%s\".\n", $TimeStamp, path($cwd,".directory");

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Print statistics for this program run, if being terse or verbose:
sub stats {
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say    STDERR '';
      say    STDERR 'Statistics for this directory tree:';
      say    STDERR "Navigated $direcount directories.";
      say    STDERR "Riffled through $filecount files.";
      say    STDERR "Processed $dlphcount Dolphin directory-settings files.";
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
