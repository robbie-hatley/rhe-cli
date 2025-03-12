#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# find-bad-jpegs.pl
# This program finds damaged jpeg files. It scans the first 3 bytes of all jpeg files (files with file name
# extensions jpg, jpeg, or pjpeg) in the current directory (and all subdirectories if a -r or --recurse option
# is used). Any such files with the first 3 bytes NOT equal to "\xFF\xD8\xFF" are reported to STDERR as being
# "corrupt". (Jpeg files are susceptable to being damaged in this way due to disk or network errors, causing
# the file to be unviewable.)
# Written by Robbie Hatley.
#
# Edit history:
# Fri Jun 19, 2015: Wrote first draft.
# Tue Jun 23, 2015: Did some fine tuning.
# Fri Jul 17, 2015: Upgraded for utf8.
# Thu Mar 03, 2016: Various minor improvements.
# Sat Apr 16, 2016: Now using -CSDA.
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory as its first
#                   argument, target as second, and regexp (instead of wildcard) as third.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and "Sys::Binmode".
# Sat Nov 27, 2021: Renamed to "find-bad-jpgs.pl". Fixed wide character error (due to sending unencrypted name to open).
# Thu Oct 03, 2024: Got rid of Sys::Binmode and common::sense; added "use utf8".
# Mon Mar 10, 2025: Got rid of given/when.
########################################################################################################################

use v5.32;
use utf8;

use Time::HiRes 'time';

use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =================================================================================

sub argv    ()  ; # Process @ARGV.
sub curdire ()  ; # Process current directory.
sub curfile ($) ; # Process current file.
sub stats   ()  ; # Print statistics.
sub error   ($) ; # Handle errors.
sub help    ()  ; # Print help and exit.

# ======= VARIABLES: ===================================================================================================

# Turn on debugging?
my $db = 0; # Set to 1 for debugging, 0 for no debugging.

# Program Settings:                                Meaning:                 Range:    Default:
my $Recurse   = 0;                               # Recurse subdirectories?  (bool)    0
my $Target    = 'F';                             # Target                   F|D|B|A   'F'
my $Regexp    = '\.(?:jpg)|(?:jpeg)|(?:pjpeg)$'; # Regular expression.      (regexp)  '\.(?:jpg)|(?:jpeg)|(?:pjpeg)$'
my $Verbose   = 0;                               # Be verbose?              (bool)    0

# Counters:
my $direcount = 0; # Count of directories processed by curdire().
my $filecount = 0; # Count of directory entries matching target and regexp.
my $badjcount = 0; # Count of bad jpeg files found.

# ======= MAIN BODY OF PROGRAM: ========================================================================================

{ # begin main
   my $t0 = time;
   argv;
   if ($Verbose) {say "\nNow entering program \"" . get_name_from_path($0) . "\".";}
   $Recurse and RecurseDirs {curdire} or curdire;
   if ($Verbose) {stats;}
   my $t1 = time; my $te = $t1 - $t0;
   if ($Verbose) {say "\nNow exiting program \"" . get_name_from_path($0) . "\". Execution time was $te seconds.";}
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ======================================================================================

sub argv ()
{
   for ( my $i = 0 ; $i < @ARGV ; ++$i )
   {
      $_ = $ARGV[$i];
      if (/^-[\pL]{1,}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/)
      {
            if ( $_ eq '-h' || $_ eq '--help'    ) {help; exit 777;}
         elsif ( $_ eq '-r' || $_ eq '--recurse' ) {$Recurse =  1 ;}
         elsif ( $_ eq '-v' || $_ eq '--verbose' ) {$Verbose =  1 ;}
         splice @ARGV, $i, 1;
         --$i;
      }
   }
   my $NA = scalar(@ARGV);
   if ( $NA > 1 ) {error($NA); help; exit(666);}
   if ( $NA > 0 ) {$Regexp = $ARGV[0]}
   return 1;
} # end sub argv ()

sub curdire ()
{
   ++$direcount;
   my $curdir = cwd_utf8;
   if ($Verbose) {say "\nDir # $direcount: $curdir\n";}
   my $curdirfiles = GetFiles($curdir, $Target, $Regexp);

   foreach my $file (@{$curdirfiles})
   {
      curfile($file);
   }
   return 1;
} # end sub curdire ()

sub curfile ($)
{
   ++$filecount;
   my $file              = shift;
   my $煎茶               = undef;
   my $первые_три_байта  = '';

   # Open file in raw mode:
   open($煎茶, "< :raw", e $file->{Path})
      or warn "Couldn't open file \"$file->{Name}\".\n$!\n"
      and return 0;

   # Read first 3 bytes of file into $первые_три_байта
   read($煎茶, $первые_три_байта, 3, 0)
      or warn "Couldn't read 3 bytes from file \"$file->{Name}\".\n"
      and (close($煎茶) or warn("Couldn't close file \"$file->{Name}\".\n"))
      and return 0;

   # Close file:
   close($煎茶)
      or warn "Couldn't close file \"$file->{Name}\".\n"
      and return 0;

   # Print bad-jpg warning if first 3 bytes of file aren't "\xFF\xD8\xFF":
   if ($первые_три_байта ne "\xFF\xD8\xFF")
   {
      ++$badjcount;
      say "BAD JPG FILE: \"$file->{Path}\"";
   }

   return 1;
} # end sub curfile ($)

sub stats ()
{
   say "\nStats for program \"find-bad-jpegs.pl\":";
   say "Navigated $direcount directories.";
   say "Examined  $filecount entries matching target \"$Target\" and regexp \"$Regexp\".";
   say "Found     $badjcount bad jpeg files.";
   return 1;
} # end sub stats ()

sub error ($)
{
   my $NA = shift;
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most one argument,
   which, if present, must be a regular expression specifying which files names
   to process. Help follows.
   END_OF_ERROR
} # end sub error ($)

sub help ()
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "find-bad-jpegs.pl".
   This program examines all files in the current directory (and all of its
   subdirectories if an -r or --recurse option is used) which have one of the
   following extentions:
   *.jpg
   *.jpeg
   *.pjpeg
   This program looks at the first few bytes of each such file, and prints
   to STDERR the full path of any such files which do not start with bytes
   255, 216, 255. (Valid jpeg files should always start with those 3 bytes.)

   Command line:
   find-bad-jpegs.pl [options] [argument]

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.
   "-r" or "--recurse"          Recurse subdirectories (but not links).
   "-v" or "--verbose"          Print directory headings and stats.

   All other options are ignored.

   Description of arguments:
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

   WARNING: Don't specify file extentions other than jpg, jpeg, or pjpeg
   unless you have reason to believe that the files you want to test
   actually should be jpeg files. Otherwise, you're likely to get a lot
   of false positives due to the files you're testing never having been
   intended to be jpeg files in the first place. Usually, it's best to
   use no argument, so that this program will look at files with names
   ending in ".jpg", ".jpeg", and ".pjpeg" only.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help ()
