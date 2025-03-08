#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# find-equivalent-names.pl
# Finds directory entries (files and/or directories) which have names which are duplicates if all of the
# ' ', '_', and '-' characters are removed. For example, this program would consider "Josh Bell.mp3",
# "Josh-Bell.mp3", and "Josh_Bell.mp3" to have "duplicate" names.
#
# Edit history:
# Wed Oct 17, 2018: Wrote first draft on-or-before this day (exact date unknown; never recorded).
# Tue Aug 04, 2020: Widened to 110; corrected comments; corrected help; v5.30; weeded "use"; etc.
# Thu Aug 06, 2020: Fixed some bugs introduced last Tuesday; now fully functional.
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory as
#                   its first argument, target as second, and regexp (instead of wildcard) as third.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Thu Oct 03, 2024: Got rid of Sys::Binmode and common::sense; added "use utf8".
# Thu Mar 06, 2025: Decreased width from 120 to 110. Increased min ver from "5.32" to "5.36". Refactored to
#                   fix bug in which some "equivalent" names were not being found. Renamed program from
#                   "find-duplicate-names.pl" to "find-equivalent-names.pl". Shebang now uses "-C63".
#                   Got rid of all prototypes and empty signatures.
##############################################################################################################

use v5.36;
use utf8;

use RH::Util;
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub equiv   ; # Do two files have equivalent names?
sub stats   ; # Print statistics.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

# ======= VARIABLES: =========================================================================================

# Turn on debugging?
my $db = 1; # Set to 1 for debugging, 0 for no debugging.

# Program settings:
my $Recurse   = 0;     # Recurse subdirectories?  (bool)
my $Target    = 'F';   # Target                   F|D|B|A
my $Regexp    = '.+';  # Regular expression.      (regexp)

# Counters:
my $direcount = 0; # Count of directories processed by curdire().
my $filecount = 0; # Count of directory entries matching target and regular expression.
my $equicount = 0; # Count of equivalent directory name pairs found.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   argv;
   $Recurse and RecurseDirs {curdire} or curdire;
   stats;
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub argv {
   my $help;
   my @CLArgs;
   foreach (@ARGV)
   {
      if (/^-[\pL\pN]{1}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/)
      {
         if ('-h' eq $_ || '--help'         eq $_) {$help    =  1 ;} # default is 0
         if ('-r' eq $_ || '--recurse'      eq $_) {$Recurse =  1 ;} # default is 0
         if ('-f' eq $_ || '--target=files' eq $_) {$Target  = 'F';} # default is D
         if ('-d' eq $_ || '--target=dirs'  eq $_) {$Target  = 'D';} # default is D
         if ('-b' eq $_ || '--target=both'  eq $_) {$Target  = 'B';} # default is D
      }
      else {push @CLArgs, $_;}
   }
   my $NA = scalar @CLArgs;
   if ($NA == 0) {             ;             } # Do nothing.
   if ($NA == 1) {$Regexp = $CLArgs[0];      } # Store regexp.
   if ($NA  > 1) {error($NA); help; exit 666;} # Print error and help messages and exit 666.
   return 1;
} # end sub argv

sub curdire {
   ++$direcount;
   my $curdir = cwd_utf8;
   say "\nDir # $direcount: $curdir";
   my $curdirfiles = GetFiles($curdir, $Target, $Regexp);
   $filecount += $RH::Dir::totfcount;
   my @sortedfiles = sort { fc($a->{Name}) cmp fc($b->{Name}) } @{$curdirfiles};
   for    ( my $i =    0   ; $i <= $#sortedfiles - 1 ; ++$i ) {
      for ( my $j = $i + 1 ; $j <= $#sortedfiles && $j <= $i + 25 ; ++$j ) {
         if ( equiv($sortedfiles[$i]->{Name},$sortedfiles[$j]->{Name}) ) {
            ++$equicount;
            say '';
            say $sortedfiles[$i]->{Path};
            say $sortedfiles[$j]->{Path};
         }
      }
   }
   return 1;
} # end sub curdire

sub equiv ($first, $second) {
   $first  =~ s/[^\pL\pN]//g;
   $second =~ s/[^\pL\pN]//g;
   return fc($first) eq fc($second);
} # end sub equiv

sub stats {
   say "\nStats for program \"find-duplicate-names.pl\":";
   say "Navigated $direcount directories.";
   say "Examined  $filecount entries matching target \"$Target\" and regexp \"$Regexp\".";
   say "Found     $equicount equivalent name pairs.";
   return 1;
} # end sub stats

sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most one argument,
   which, if present, must be a regular expression specifying which files names
   to process.
   END_OF_ERROR
   return 1;
} # end sub error

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "find-duplicate-names.pl". This program finds directory entries
   (files and/or directories) in the current directory (and all subdirectories if
   a -r or --recurse option is used) which have names which are the same if all
   of the non-alpha-numeric characters are removed. For example, this program
   would consider "Josh Bell.mp3", "Josh-Bell.mp3", and "Josh_Bell.mp3" to have
   "duplicate" names.

   Command line:
   find-duplicate-names.pl [options and/or arguments]

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.
   "-r" or "--recurse"          Recurse subdirectories. (Default is "no recurse".)
   "-f" or "--target=files"     Target files only. (DEFAULT)
   "-d" or "--target=dirs"      Target directories only.
   "-b" or "--target=both"      Target both files and directories.
                                (Note: specifying "All" is NOT allowed because
                                that would bypass glob_regexp_utf8's "noex"
                                rejection.)

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

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
