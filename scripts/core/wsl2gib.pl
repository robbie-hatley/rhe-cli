#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# wsl2gib.pl
# Renames each file in the current directory (and all subdirectories if a -r or --recurse option is used)
# which has a 64-character "Windows Spotlight"-style file name to a name consisting of 8 random lower-case
# letters followed by the original file name extension.
#
# Edit history:
# Fri Oct 23, 2020: Wrote it.
# Mon Dec 21, 2020: Now also has recursion available.
# Sun Jan 03, 2021: Now also processes many other file types besides just jpg.
# Mon Feb 15, 2021: Dramatically simplied. File names can now have any extension or none.
#                   Renamed to "wsl-to-gib.pl". [Note, 2023-08-08: From what, I wonder?]
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Tue Aug 08, 2023: Upgraded from "v5.32" to "v5.36". Renamed from "wsl-to-gib.pl" to "wsl2gib.pl".
#                   Reduced width from 120 to 110.
# Sat Apr 05, 2025: Now using "Cwd::utf8"; nixed "cwd_utf8".
##############################################################################################################

use v5.36;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;
use Cwd::utf8;
use Time::HiRes 'time';

use RH::Util;
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ;
sub curdire ;
sub curfile ;
sub stats   ;
sub help    ;

# ======= VARIABLES: =========================================================================================

# Debug?
my $db = 0;

# Windows SpotLight file-name pattern:
my $wsl = qr(^[0-9a-z]{64}(?:-\(\d{4}\))?(?:\.[a-zA-Z]+)?$);

# Settings:
my $Recurse = 0; # Recurse subdirectories?

# Counters:
my $direcount = 0; # Count of directories processed by curdire().
my $filecount = 0; # Count of wsl file names found.
my $renacount = 0; # Count of files renamed.
my $failcount = 0; # Count of failed file-rename attempts.

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
   for (@ARGV) {
      if ('-h' eq $_ || '--help'    eq $_) {$help    = 1;}
      if ('-r' eq $_ || '--recurse' eq $_) {$Recurse = 1;}
   }
   if ($help) {help; exit 777;}
   return 1;
} # end sub argv

sub curdire {
   ++$direcount;
   my $curdir = cwd;
   say "\nDir # $direcount: \"$curdir\"\n";
   for my $path ( glob_regexp_utf8($curdir, 'F', $wsl) ) {
      curfile($path);
   }
   return 1;
} # end sub curdire

sub curfile ($path) {
   ++$filecount;
   my $name     = get_name_from_path($path);
   my $dir      = get_dir_from_path($path);
   my $suff     = get_suffix($name);
   my $new_name = find_avail_rand_name($dir, '', $suff);
   $new_name eq '***ERROR***'
   and ++$failcount
   and warn "Unable to find available random name.\n"
   and return 0;
   rename_file($name, $new_name)
   and ++$renacount
   and say "Renamed \"$name\" to \"$new_name\""
   and return 1
   or  ++$failcount
   and warn "FAILED to rename \"$name\" to \"$new_name\"\n"
   and return 0;
} # end sub curfile ($path)

sub stats {
   print("\nStats for \"wsl2gib.pl\":\n");
   printf("Navigated %6u directories.\n",           $direcount);
   printf("Found     %6u files with wsl names.\n",  $filecount);
   printf("Renamed   %6u files.\n",                 $renacount);
   printf("Failed    %6u file-rename attempts.\n",  $failcount);
   return 1;
} # end sub stats

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "wsl2gib.pl". This program renames all regular files in the
   current directory (and all subdirectories if a -r or --recurse option is used)
   which have 64-character Windows-Spotlight-style file names
   to names consisting of 8 lower case letters
   followed by the file name extension of the original file.

   Command line:
   wsl2gib.pl [options]

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
