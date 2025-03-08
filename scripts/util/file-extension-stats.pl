#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# file-extension-stats.pl
# Prints how many files of each name-extension ("*.jpg", "*.avi", etc) exist in directories.
# Written by Robbie Hatley.
#
# Edit history:
# Sun Feb 21, 2021: Wrote it. Later that day, fine-tuned it a bit.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Thu Aug 03, 2023: Upgraded from "use v5.32;" to "use v5.36;". Changed name from "file-type-statistics.pl"
#                   to "file-extension-stats.pl". Got rid of "use common::sense;" (antiquated). Reduced
#                   width from 120 to 110 for github. Shortened sub names. Got rid of prototypes and started
#                   using signatures instead. Improved help.
# Thu Sep 07, 2023: Updated and simplified argv. Removed "quotes" from help. Added "warnings Fatal => 'utf8'".
#                   Added --debug and --local settings. Subsumed curfile() into curdir() as one-liner.
#                   Now considering ".htm", ".html", ".HTM", ".HTML" as being 4 different extensions.
#                   (Program was hiding those differences, but that's a mistake, as we need to see what
#                   non-cannonical file-name extensions are being used, so we can fix them.)
# Thu Oct 03, 2024: Got rid of Sys::Binmode.
# Thu Mar 06, 2025: Nixed "strict" and "warnings".
##############################################################################################################

use v5.36;
use utf8;

use Cwd;

use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ;
sub curdire ;
sub curfile ;
sub stats   ;
sub help    ;

# ======= VARIABLES: =========================================================================================

# Turn on debugging?
my $Db = 0; # Set to 1 for debugging, 0 for no debugging.

#Program Settings:
#  Setting:           Meaning:                  Range:   Default:
my $Recurse = 0 ;   # Recurse subdirectories?   (bool)   0
my $Number  = 0 ;   # Sort by number of files?  (bool)   0

# Counters:
my $direcount = 0; # Count of directories processed by process_current_directory().
my $filecount = 0; # Count of    files    processed by process_current_file().

# File types counter hash (how many files have we seen of each type?):
my %file_types;

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   argv;
   $Recurse and RecurseDirs {curdire} or curdire;
   stats;
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub argv {
   # Get options and ignore arguments:
   my @opts;                 # options
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {                             # For each command-line item,
      if ( /^-(?!-)$s+$/ || /^--(?!-)$d+$/ ) { # if its a valid short or long option,
         push @opts, $_;                       # push item to @opts.
      }
   }

   # Process options:
   for ( @opts ) {
      /^-$s*h/ || /^--help$/    and help and exit 777 ;
      /^-$s*e/ || /^--debug$/   and $Db      =  1     ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0     ;
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1     ;
      /^-$s*n/ || /^--number$/  and $Number  =  1     ;
   }
   if ( $Db ) {
      say STDERR '';
      say STDERR "\$opts = (", join(', ', map {"\"$_\""} @opts), ')';
   }

   # Return success code 1 to caller:
   return 1;
} # end sub process_argv ()

sub curdire {
   ++$direcount;
   my $curdir = d getcwd;
   my @curdirpaths = glob_regexp_utf8($curdir, 'F');
   ++$file_types{get_suffix get_name_from_path $_} for @curdirpaths;
   return 1;
} # end sub curdire

sub stats {
   say 'File-extension statistics for this ' . ($Recurse ? 'tree:' : 'directory:');
   printf("Extension:  Count:\n");
   my @sorted_keys;
   if ($Number) {
      @sorted_keys = sort {$file_types{$b} <=> $file_types{$a}} keys %file_types;
   }
   else {
      @sorted_keys = sort keys %file_types;
   }
   printf("%-12s%6d\n", $_, $file_types{$_}) for @sorted_keys;
   return 1;
} # end sub stats

sub help
{
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "file-extension-stats.pl". This program prints how many files of
   each name-extension ("*.jpg", "*.avi", etc) exist in the current directory
   (and all subdirectories if a -r or --recurse option is used).

   -------------------------------------------------------------------------------
   Command lines:
   file-types-statistics.pl [-h|--help]   (to print this help and exit)
   file-types-statistics.pl [options]     (to print file-extension stats)

   -------------------------------------------------------------------------------
   Description Of Options:

   Option:           Meaning:
   -h or --help      Print this help and exit.
   -e or --debug     Print diagnostics.
   -l or --local     Don't recurse subdirectories.   (DEFAULT)
   -r or --recurse   Recurse subdirectories.
   -n or --number    Sort by number-of-files instead of by extension.

   Any options not listed above will be ignored.

   -------------------------------------------------------------------------------
   Description Of Arguments:

   All non-option arguments will be ignored.

   Happy file-extension stats printing!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
} # end sub help
