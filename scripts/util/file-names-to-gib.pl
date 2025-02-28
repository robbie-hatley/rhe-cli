#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# file-names-to-sha1.pl
# Converts the names of (nearly) all files in the current directory (and also all subdirectories if a -r or
# --recurse option is used) to the sha1 hashes of the files. (Bypasses '.', '..', '*.ini', '*.db', '*.jbf'.)
# Written by Robbie Hatley.
#
# Edit history:
# Fri Feb 28, 2025: Wrote it.
##############################################################################################################

use v5.36;
use utf8;
use RH::Util;
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
sub help    ; # Print help.

# ======= GLOBAL VARIABLES: ==================================================================================

our $t0     ; # Seconds since 00:00:00, Thu Jan 1, 1970, at the time of program entry.
our $t1     ; # Seconds since 00:00:00, Thu Jan 1, 1970, at the time of program exit.

# ======= START TIMER: =======================================================================================

BEGIN {$t0 = time}

# ======= LEXICAL VARIABLES: =================================================================================

#Settings:
my $Recurse   = 0; # Recurse subdirectories? (Default is no-recurse.) (Overrideable.)

# Counters:
my $direcount = 0; # Count of directories processed by curdire().
my $filecount = 0; # Count of all files processed by curfile().
my $bypacount = 0; # Count of files bypassed.
my $renacount = 0; # Count of files successfully renamed.
my $failcount = 0; # Count of failed file-rename attempts.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Process @ARGV:
   argv;

   # Set program name:
   my $pname = substr $0, 1 + rindex $0, '/';

   # Print program entry message:
   say STDERR "\nNow entering program \"$pname\" at timestamp $t0.";

   warn
   "WARNING!!! THIS PROGRAM CONVERTS THE NAMES OF (NEARLY) ALL FILES IN THE\n".
   "CURRENT DIRECTORY (AND ALSO ALL SUBDIRECTORIES IF A -r OR --recurse OPTION\n".
   "IS USED) TO STRINGS OF 8 RANDOM lower-case LETTERS. (BYPASSES \".\", \"..\",\n".
   "\"*.ini\", \"*.db\", AND \"*.jbf\" FILES.) ALL EXISTING FILE NAMES WILL BE\n".
   "OBLITERATED!!! ARE YOU SURE THIS IS REALLY WHAT YOU WANT TO DO???\n".
   "PRESS 'G' (shift-g) TO CONTINUE, OR ANY OTHER KEY TO ABORT.\n";
   my $char = get_character;
   if ($char ne 'G') {exit 0;}
   $Recurse and RecurseDirs {curdire} or curdire;
   stats;

   # Print exit message:
   $t1 = time;
   my $ms = 1000 * ($t1-$t0);
   say    STDERR '';
   say    STDERR "Now exiting program \"$pname\" at timestamp $t1.";
   printf STDERR "Execution time was %.3fms.", $ms;

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub argv {
   foreach (@ARGV)
   {
      if ('-h' eq $_ || '--help'    eq $_) {help; exit 777;}
      if ('-r' eq $_ || '--recurse' eq $_) {$Recurse = 1;}
   }
   return 1;
} # end sub argv

sub curdire {
   # Increment directory counter:
   ++$direcount;

   # Get and announce current working directory:
   my $curdir = cwd_utf8;
   say '';
   say "Dir # $direcount: $curdir";

   # Get a list of all paths in current directory:
   my ($dh, @paths);
   opendir($dh, e $curdir)
   or die "Error in \"file-names-to-sha1.pl\":\n".
          "Couldn't open directory \"$curdir\"!\n".
          "${!}!\n";
   @paths = d readdir $dh;
   closedir $dh;

   # Send each path to curfile:
   foreach my $path (@paths)
   {
      if ( ! is_data_file($path) )
      {
         ++$bypacount;
         next;
      }
      my $result = curfile($path);
      if ( $result )
      {
         ++$renacount;
      }
      else
      {
         ++$failcount;
      }
   }
   return 1;
} # end sub curdire

# Process current file.
# (Warning: This subroutine has a bad attitude.)
sub curfile ($)
{
   ++$filecount;
   my $path = shift;
   my $name = get_name_from_path($path);
   my $newname = hash($path, 'sha1', 'name');
   rename_file($name, $newname)
   and say "Renamed \"$name\" to \"$newname\"."
   and return 1
   or warn "Failed to rename \"$name\" to \"$newname\".\n"
   and return 0;
} # end sub curfile

sub stats ()
{
   print("\nStats for program \"file-names-to-sha1.pl\":\n");
   printf("Navigated %6u directories.\n",          $direcount);
   printf("Found     %6u files.\n",                $filecount);
   printf("Bypassed  %6u files.\n",                $bypacount);
   printf("Renamed   %6u files.\n",                $renacount);
   printf("Failed    %6u file-rename attempts.\n", $failcount);
   return 1;
} # end sub stats

sub help ()
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "file-names-to-sha1.pl". This program renames all files in the
   current directory (and all subdirectories if a -r or --recurse option is used)
   to names consisting of the SHA-1 hash of the data in the file followed by the
   file's original name extension. This can be useful for unidentified image files
   which you want to indentify via Internet databases of SHA-1 hashes of files.

   WARNING!!! THIS PROGRAM CONVERTS THE NAMES OF (NEARLY) ALL FILES IN THE
   CURRENT DIRECTORY (AND ALSO ALL SUBDIRECTORIES IF A -r or --recurse OPTION
   IS USED) TO THE SHA1 HASHES OF THE FILES. (Bypasses '.', '..', 'desktop*.ini',
   'thumbs*.db', and 'pspbrwse*.jbf'.) IT OBLITERATES ALL EXISTING FILE NAMES!!!
   ONLY USE THIS PROGRAM IF THAT'S WHAT YOU REALLY WANT TO DO!!!

   Command line:
   file-names-to-sha1.pl [options]

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.
   "-r" or "--recurse"          Recurse subdirectories.

   This program recognizes no other options, and takes no arguments.
   All arguments and non-listed options will be ignored.

   Final warning: this program is DANGEROUS!!!
   My Vishnu and Laxmi have mercy on you.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
