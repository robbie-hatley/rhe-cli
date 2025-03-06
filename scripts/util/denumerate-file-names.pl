#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# denumerate-file-names.pl
# Removes all "numerators" of the form "-(####)" (where # means "random digit") from prefixes of the names of
# every file in the current working directory (and all of its subdirectories if a "-r" or "--recurse" option
# is used). This is useful after aggregation and de-duping of files with the same name prefix and possibly
# the same content.
#
# Also check-out the following programs, which are intended to be used  in conjunction with this program:
# "dedup-files.pl"
# "dedup-newsbin-files.pl"
# "enumerate-file-names.pl"
#
# Author: Robbie Hatley.
#
# Edit history:
# Mon Apr 27, 2015: Wrote first draft. Kinda skeletal at this point. Stub.
# Thu Apr 30, 2015: Made many additions and changes. Now fully functional.
# Mon Jul 06, 2015: Corrected some minor errors.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Mon Dec 25, 2017: Added and corrected comments.
# Mon Feb 24, 2020: Changed width to 110 and added entry, stats, and exit announcements.
# Tue Jan 19, 2021: Heavily refactored. Got rid of all global vars, now using prototypes, etc.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Sat Dec 04, 2021: Now using regexp instead of wildcard.
# Wed Mar 15, 2023: Added options for local, recursive, quiet, and verbose.
# Sat Aug 19, 2023: Upgraded from "v5.32" to "v5.36". Reduced width from 120 to 110. Got rid of CPAN module
#                   "common::sense" (antiquated). Got rid of all prototypes. Now using signatures.
# Sun Aug 20, 2023: Now printing diagnostics, errors, and stats to STDERR, but everything else to STDOUT.
# Mon Aug 21, 2023: Increased parallelism between "denumerate-file-names.pl" and "enumerate-file-names.pl".
# Mon Aug 21, 2023: An "option" is now "one or two hyphens followed by 1-or-more word characters".
#                   Reformatted debug printing of opts and args to ("word1", "word2", "word3") style.
#                   Inserted text into help explaining the use of "--" as "end of options" marker.
# Mon Aug 28, 2023: Clarified sub argv().
#                   Got rid of "/...|.../" in favor of "/.../ || /.../" (speeds-up program).
#                   Simplified way in which options and arguments are printed if debugging.
#                   Removed "$" = ', '" and "$, = ', '". Got rid of "/o" from all instances of qr().
#                   Changed all "$db" to $Db". Debugging now simulates renames instead of exiting in main.
#                   Removed "no debug" option as that's already default in all of my programs.
#                   Changed short option for debugging from "-e" to "-d".
# Wed Aug 14, 2024: Removed unnecessary "use" statements. Changed short option for debug from "-d" to "-e".
# Tue Mar 04, 2025: Now using global "t0" and "BEGIN" block to start timer.
##############################################################################################################

use v5.36;
use utf8;
use Cwd;
use Time::HiRes 'time';
use RH::Dir;

# ======= GLOBAL VARIABLES: ==================================================================================

our $t0;

# ======= BEGIN AND END BLOCKS: ==============================================================================

BEGIN {
   $t0 = time;
}

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

# ======= VARIABLES: =========================================================================================

# Settings:                      Meaning of setting:          Range:    Meaning of default:
my $Db        = 0            ; # Debug (print diagnostics)?   bool      Don't print diagnostics.
my $Verbose   = 0            ; # Be verbose?                  bool      Be quiet.
my $Recurse   = 0            ; # Recurse subdirectories?      bool      Don't recurse.
my $RegExp    = qr/^[^.].+$/ ; # What files to enumerate?     regexp    Process only non-hidden files.

# Counters:
my $direcount = 0 ; # Count of directories processed.
my $filecount = 0 ; # Count of files processed.
my $bypacount = 0 ; # Count of files bypassed because they were not numerated.
my $skipcount = 0 ; # Count of files skipped because a file with same name base exists in the same directory.
my $attecount = 0 ; # Count of file rename attempts.
my $succcount = 0 ; # Count of files successfully renamed.
my $failcount = 0 ; # Count of failed file rename attempts.
my $simucount = 0 ; # Count of file-rename simulations.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   argv;
   my $pname = get_name_from_path($0);
   if ( $Verbose ) {
      say STDERR '';
      say STDERR "Now entering program \"$pname\".";
      say STDERR "\$Db      = $Db";
      say STDERR "\$Verbose = $Verbose";
      say STDERR "\$Recurse = $Recurse";
      say STDERR "\$RegExp  = $RegExp";
   }

   $Recurse and RecurseDirs {curdire} or curdire;

   stats;

   if ( $Verbose ) {
      my $te = time - $t0;
      say    STDERR '';
      say    STDERR "Now exiting program \"$pname\".";
      printf STDERR "Execution time was %.3f seconds.", $te;
   }
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub argv {
   # Get options and arguments:
   my @opts = ()            ; # options
   my @args = ()            ; # arguments
   my $end = 0              ; # end-of-options flag
   my $s = '[a-zA-Z0-9]'    ; # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]' ; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {
      /^--$/                  # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1            # so if we see that, then set the "end-of-options" flag
      and next;               # and skip to next element of @ARGV.
      !$end                   # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/      # and if we get a valid short option
      ||   /^--(?!-)$d+$/ )   # or a valid long option,
      and push @opts, $_      # then push item to @opts
      or  push @args, $_;     # else push item to @args.
   }

   # Process options:
   for ( @opts ) {
      /^-$s*h/ || /^--help$/    and help and exit 777 ;
      /^-$s*e/ || /^--debug$/   and $Db      =  1     ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0     ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  1     ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0     ;
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1     ;

   }
   if ( $Db ) {
      say STDERR '';
      say STDERR "\$opts = (", join(', ', map {"\"$_\""} @opts), ')';
      say STDERR "\$args = (", join(', ', map {"\"$_\""} @args), ')';
   }

   # Process arguments:
   my $NA = scalar(@args);             # Get number of arguments.
   $NA >= 1                            # If number of arguments >= 1,
   and $RegExp = qr/$args[0]/;         # set $RegExp.
   $NA >= 2 && !$Db                    # If number of arguments >= 2 and we're not debugging,
   and error($NA)                      # print error message
   and help                            # and print help message
   and exit 666;                       # and exit, returning The Number Of The Beast.

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Increment directory counter:
   ++$direcount;

   # Get current working directory:
   my $cwd = d getcwd;

   # Announce current working directory:
   say STDOUT '';
   say STDOUT "Directory # $direcount: $cwd";

   # Get list of file-info packets in $cwd matching $Target and $RegExp:
   my $curdirfiles = GetFiles($cwd, 'F', $RegExp);

   # Iterate through $curdirfiles and send each file to curfile():
   foreach my $file ( @$curdirfiles ) {
      curfile($file);
   }
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($file) {
   # Increment file counter:
   ++$filecount;

   # Get path and name:
   my $path = $file->{Path};
   my $name = $file->{Name};

   # Bypass this file if it isn't numerated:
   if ( get_prefix($name) !~ m/-\(\d\d\d\d\)$/ ) {
      ++$bypacount;
      return 1;
   }

   # Set $newname to a denumerated version of $name:
   my $newname = denumerate_file_name($name);

   # Skip this file if a file with the same base name already exists in this directory:
   if ( -e e $newname ) {
      say STDOUT '';
      say STDOUT "Can't denumerate \"$name\" because file with same base name already exists.";
      ++$skipcount;
      return 1;
   }

   # If debugging, simulate rename then return without attempting any actual rename:
   if ( $Db ) {
      ++$simucount;
      say STDOUT '';
      say STDOUT "File rename simulation #$simucount:";
      say STDOUT "Old name: $name";
      say STDOUT "New name: $newname";
      return 1;
   }

   # If we get to here, attempt to rename the file from $name to $newname:
   ++$attecount;
   say STDOUT '';
   say STDOUT "File rename attempt #$attecount:";
   say STDOUT "Old name: $name";
   say STDOUT "New name: $newname";
   if ( rename_file($name, $newname) ) {
      ++$succcount;
      say STDOUT "File successfully renamed!";
      return 1;
   }
   else {
      ++$failcount;
      say STDOUT "File rename failed!";
      return 0;
   }
} # end sub curfile ($file)

# Print statistics for this program run:
sub stats {
   if ( $Verbose ) {
      say    STDERR '';
      say    STDERR 'Statistics for program "denumerate-file-names.pl":';
      printf STDERR "Traversed   %6u directories.           \n", $direcount;
      printf STDERR "Found       %6u files matching RegExp. \n", $filecount;
      printf STDERR "Bypassed    %6u unnumerated files.     \n", $bypacount;
      printf STDERR "Skipped     %6u undenumerable files.   \n", $skipcount;
      printf STDERR "Attempted   %6u file renames.          \n", $attecount;
      printf STDERR "Denumerated %6u files.                 \n", $succcount;
      printf STDERR "Failed      %6u file rename attempts.  \n", $failcount;
      printf STDERR "Simulated   %6u file renames.          \n", $simucount;
   }
   return 1;
} # end sub stats

# Handle errors:
sub error ($NA)
{
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most 1 argument,
   which, if present, must be a Perl-Compliant Regular Expression specifying
   which files to denumerate. Help follows:
   END_OF_ERROR
} # end sub error ($NA)

# Print help:
sub help
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to DenumerateFileNames, Robbie Hatley's file-denumerating script. This
   program removes all "numerators" of the form "-(####)" (where "#" is any digit)
   from the ends of the prefixes of all regular files in the current working
   directory (and all of its subdirectories if a -r or --recurse option is used).

   -------------------------------------------------------------------------------
   Command Lines:

   denumerate-file-names.pl [-h|--help]        (to print this help and exit)
   denumerate-file-names.pl [options] [Arg1]   (to denumerate file names)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.
   -e or --debug      Print diagnostics and simulate renames.
   -q or --quiet      DON'T print directories and stats.      (DEFAULT)
   -v or --verbose    DO    print directories and stats.
   -l or --local      DON'T recurse subdirectories.           (DEFAULT)
   -r or --recurse    DO    recurse subdirectories.

         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively process items.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: hdrlvq.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   In addition to options, this program can take one optional argument which, if
   present, must be a Perl-Compliant Regular Expression specifying which items to
   process. To specify multiple patterns, use the | alternation operator.
   To apply pattern modifier letters, use an Extended RegExp Sequence.
   For example, if you want to search for items with names containing "cat",
   "dog", or "horse", title-cased or not, you could use this regexp:
   '(?i:c)at|(?i:d)og|(?i:h)orse'
   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   Happy file denumerating!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
__END__
