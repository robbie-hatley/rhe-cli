#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# wsl2sha1.pl
# Renames each file in the current directory (and all subdirectories if a -r or --recurse option is used)
# which has a 64-character "Windows Spotlight"-style file name to a name consisting of the sha1 hash of
# the data in the file followed by the original file name extension.
#
# Edit history:
# Wed Nov 11, 2020: Wrote "gib-to-sha1.pl".
# Mon Dec 21, 2020: Now also has recursion available.
# Tue Aug 08, 2023: Upgraded from "v5.32" to "v5.36". Renamed from "wsl-to-sha1.pl" to "wsl2sha1.pl".
#                   Reduced width from 120 to 110.
# Sat Apr 05, 2025: Now using "Cwd::utf8"; nixed "cwd_utf8".
##############################################################################################################

use v5.36;
use utf8;
use Cwd;
use Time::HiRes 'time';
use Digest::SHA1 qw(sha1_hex);
use RH::Dir;
use RH::Util;

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
   my $curdir = d getcwd;
   say "\nDir # $direcount: \"$curdir\"\n";
   for my $path ( glob_regexp_utf8($curdir, 'F', $wsl) ) {
      curfile($path);
   }
   return 1;
} # end sub curdire

sub curfile ($path) {
   ++$filecount;
   my $name     = get_name_from_path($path);
   my $new_name = hash($path, 'sha1', 'name');
   rename_file($name, $new_name)
   and ++$renacount
   and say "Renamed \"$name\" to \"$new_name\""
   and return 1
   or  ++$failcount
   and warn "FAILED to rename \"$name\" to \"$new_name\"\n"
   and return 0;
} # end sub curfile ($path)

sub stats {
   print("\nStats for \"wsl2sha1.pl\":\n");
   printf("Navigated %6u directories.\n",           $direcount);
   printf("Found     %6u files with wsl names.\n",  $filecount);
   printf("Renamed   %6u files.\n",                 $renacount);
   printf("Failed    %6u file-rename attempts.\n",  $failcount);
   return 1;
} # end sub stats

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "wsl2sha1.pl". This program renames all regular files in the
   current directory (and all subdirectories if a -r or --recurse option is used)
   which have 64-character Windows-Spotlight-style file names
   to names consisting of the SHA-1 hash of the data in the file
   followed by the file name extension of the original file.

   Command line:
   wsl2sha1.pl [options]

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
