#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# rdj.pl
# Removes all Thumbs.db (windows thumbnail database) and pspbrwse.jbf (Jasc Browser File) files
# from the current working directory (and also from all of its subdirectories if a "-r" or "-recurse" option
# is used). Also removes all desktop.ini (Windows desktop) files if a -i or --ini option is used.
# Written by Robbie Hatley on Sunday January 31, 2016.
# Edit history:
# Sun Jan 31, 2016: Wrote it.
# Fri Apr 15, 2016: Updated for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Mon Dec 18, 2017: Corrected formatting, comments, and help_msg.
# Thu Oct 11, 2018: Now also erasing desktop.ini if -i or --ini.
# Fri Oct 12, 2018: Added "verbose" mode (announces directories).
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Mon Nov 22, 2021: Dramatically shortened names of subroutines. Also fixed major bug which was causing this
#                   program to fail to find any db, jbf, or ini files (turned out to be a $_ issue).
# Thu Sep 07, 2023: Reduced width from 120 to 110. Upgraded from "v5.32" to "v5.36". Now using "strict",
#                   "warnings", "utf8", and "warnings FATAL => 'utf8'". Changed "$db to "$Db".
#                   Got rid of "common::sense" (antiquated). Got rid of "Unicode::Normalize" (unnecessary).
#                   Entry/exit msgs, diagnostics, stats, warnings, errors now go to STDERR.
#                   Lines pertaining to the processing of specific files  now go to STDOUT.
#                   Updated argv to my latest @ARGV-handling technology. Moved all regexps to qr// variables.
#                   Updated help to my latest formatting standard. Changed most bracing to C-style.
#                   Got rid of "quiet" and "verbose" options; just print everything.
##############################################################################################################

use v5.36;
use strict;
use warnings;
use utf8;
use warnings FATAL => 'utf8';

use Cwd;
use Time::HiRes 'time';

use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS ========================================================================

sub argv;
sub curdire;
sub stats;
sub help;

# ======= GLOBAL VARIABLES ===================================================================================

# Settings:
#  Setting:   Default:    Meaning of setting:        Range:    Meaning of default:
my $Db        = 0 ;   #   Print diagnostics?         bool      Don't print diagnostics.
my $Recurse   = 0 ;   #   Recurse subdirectories?    bool      Don't recurse.
my $Ini       = 0 ;   #   Also erase desktop.ini?    bool      Don't erase ini files.

# Counters:
our $direcount = 0; # Count of directories processed.
our $Dbfdcount = 0; # Count of Thumbs*.db  files found.
our $Dbercount = 0; # Count of Thumbs*.db  files erased.
our $Dbnecount = 0; # Count of Thumbs*.db  files not erased.
our $jbfdcount = 0; # Count of pspbrwse*.jbf files found.
our $jbercount = 0; # Count of pspbrwse*.jbf files erased.
our $jbnecount = 0; # Count of pspbrwse*.jbf files not erased.
our $difdcount = 0; # Count of desktop*.ini files found.
our $diercount = 0; # Count of desktop*.ini files erased.
our $dinecount = 0; # Count of desktop*.ini files not erased.

# Regular expressions:
my $thmpat = qr/^thumbs(-\(\d{4}\))*\.db/i;
my $psppat = qr/^pspbrwse(-\(\d{4}\))*\.jbf$/i;
my $dskpat = qr/^desktop(-\(\d{4}\))*\.ini$/i;

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Set time and program variables:
   my $t0 = time;
   my $pname = substr $0, 1 + rindex $0, '/';

   # Process @ARGV:
   argv;

   # Print entry message:
   say    STDERR "Now entering program \"$pname\"." ;
   say    STDERR "\$Db        = $Db"        ;
   say    STDERR "\$Recurse   = $Recurse"   ;
   say    STDERR "\$Ini       = $Ini"       ;

   # Process current directory (and all subdirectories if recursing):
   $Recurse and RecurseDirs {curdire} or curdire;

   # Print stats:
   stats;

   # Print exit message:
   say    STDERR '';
   say    STDERR "Now exiting program \"$pname\".";
   printf STDERR "Execution time was %.3fms.", 1000 * (time - $t0);

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub argv {
   # Get options:
   my @opts;                 # options
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {
      if ( /^-(?!-)$s+$/ ||  /^--(?!-)$d+$/ ) { # If we get a valid short or long option,
         push @opts, $_;                        # push item to @opts.
      }
   }

   # Process options:
   for ( @opts ) {
      /^-$s*h/ || /^--help$/    and help and exit 777 ;
      /^-$s*e/ || /^--debug$/   and $Db      = 1      ;
      /^-$s*l/ || /^--local$/   and $Recurse = 0      ;
      /^-$s*r/ || /^--recurse$/ and $Recurse = 1      ;
      /^-$s*i/ || /^--ini$/     and $Ini     = 1      ;
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

sub curdire
{
   ++$direcount;

   # Get current working directory:
   my $curdir = d getcwd;

   # Announce current working directory:
   say STDOUT '';
   say STDOUT "Directory #$direcount: $curdir";

   # Get list of directory entries:
   my $dh = undef;
   opendir($dh, e $curdir)     or die "Can't open  directory \"$curdir\"\n$!\n";
   my @entries = d readdir $dh or die "Can't read  directory \"$curdir\"\n$!\n";
   closedir($dh)               or die "Can't close directory \"$curdir\"\n$!\n";

   if ( $Db ) {
      say STDERR '';
      say STDERR 'Directory entries:';
      say STDERR for @entries;
      say STDERR '';
   }

   # Get lists of db, jbf, and ini files:
   my @db;
   my @jbf;
   my @ini;
   ENTRY: foreach my $entry ( @entries ) {
      if ( $Db ) {
         say STDERR '';
         say STDERR 'current entry:';
         say STDERR $entry;
         say STDERR '';
      }

      # Skip '.', '..', directories, and non-regular files:
      next ENTRY if $entry eq '.';
      next ENTRY if $entry eq '..';
      next ENTRY if   -d e $entry;
      next ENTRY if   -l e $entry;
      next ENTRY if ! -f e $entry;

      if ( $entry =~ $thmpat ) {
         say STDERR " db: $entry" if $Db;
         push(@db, $entry);
         ++$Dbfdcount;
      }

      if ( $entry =~ $psppat ) {
         say STDERR "jbf: $entry" if $Db;
         push(@jbf, $entry);
         ++$jbfdcount;
      }

      if ($entry =~ $dskpat && $Ini) {
         say STDERR "ini: $entry" if $Db;
         push(@ini, $entry);
         ++$difdcount;
      }
   }

   if ( $Db ) {
      say STDERR '';
      say STDERR 'db files found:';
      say STDERR for @db;
      say STDERR '';
      say STDERR 'jbf files found:';
      say STDERR for @jbf;
      say STDERR '';
      say STDERR 'ini files found:';
      say STDERR for @ini;
      say STDERR '';
   }

   # Try to erase each file in @db :
   foreach ( @db ) {
      unlink(e($_)) and ++$Dbercount and say STDOUT "erased: $_"
                     or ++$Dbnecount and say STDOUT "couldn't erase: $_";
   }

   # Try to erase each file in @jbf :
   foreach ( @jbf ) {
      unlink(e($_)) and ++$jbercount and say STDOUT "erased: $_"
                     or ++$jbnecount and say STDOUT "couldn't erase: $_";
   }

   # If also erasing ini files, try to erase each file in @ini :
   if ($Ini) {
      foreach ( @ini ) {
         unlink(e($_)) and ++$diercount and say STDOUT "erased: $_"
                        or ++$dinecount and say STDOUT "couldn't erase: $_";
      }
   }

   return 1;
} # end sub curdire

sub stats
{
   say STDERR ''                                                                     ;
   say STDERR 'Statistics for "rdj.pl":'                                             ;
   say STDERR "Navigated $direcount directories."                                    ;
   say STDERR "Found $Dbfdcount Thumbs*.db files."                                   ;
   say STDERR "Erased $Dbercount Thumbs*.db files."                                  ;
   say STDERR "Tried but failed to erase $Dbnecount Thumbs*.db files."               ;
   say STDERR "Found $jbfdcount pspbrwse*.jbf files."                                ;
   say STDERR "Erased $jbercount pspbrwse*.jbf files."                               ;
   say STDERR "Tried but failed to erase $jbnecount pspbrwse*.jbf files."            ;
   say STDERR "Found $difdcount desktop*.ini files."                       if ($Ini) ;
   say STDERR "Erased $diercount desktop*.ini files."                      if ($Ini) ;
   say STDERR "Tried but failed to erase $dinecount desktop*.ini files."   if ($Ini) ;
   return 1;
} # end sub stats

sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "rdj.pl". This program erases the following files from the current
   directory (and from all subdirectories if a -r or --recurse option is used):
   Thumbs.db    (Windows thumbnail database files)
   pspbrwse.jbf (Jasc Browser Files used by Paint Shop Pro)
   desktop.ini  (Windows desktop settings) (only if an -i or --ini option is used)

   Variants with weird casings (eg, "ThUmBs.db") or numerators
   (eg, "desktop-(3048).ini") will also be erased.

   However, variants with added material other than numerators
   (eg, "my-desktop.ini") will NOT be erased, because they may be files which are
   NOT windows thumbnails, PSP browse files, or Windows desktop-settings files.

   Note on program name: "rdj" stands for "Remove Db and Jbf files". I considered
   naming this program "remove-db-and-jbf-and-ini-files.pl", but that was WAY too
   much to type; I like "rdj.pl" much better. :-)

   -------------------------------------------------------------------------------
   Command lines:

   rdj.pl [-h | --help]    (to print this help and exit)
   rdj.pl [options]        (to remove junk files)

   -------------------------------------------------------------------------------
   Description of options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics.
   -l or --local      DON'T recurse subdirectories.     (DEFAULT)
   -r or --recurse    DO    recurse subdirectories.
   -i or --ini        Also erase desktop.ini files.

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -ir to recursively delete db, jbf, and ini files.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: heirl.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of arguments:

   All non-option arguments are ignored.


   Happy junk-file removing!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
