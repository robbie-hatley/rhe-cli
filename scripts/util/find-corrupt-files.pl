#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# find-corrupt-files.pl
# Ginds all files in the current directory (and subdirectories if using "-r" or "--recurse") which were
# last modified in October 2014 and have the following as their first 16 bytes:
# BB 1A E3 1E 3C 26 C2 62 57 E2 63 F3 27 4F 7C A3
# Such files have been corrupted by particularly nasty virus and need to be quarantined.
#
# Author: Robbie Hatley
#
# Edit history:
# Fri Jun 12, 2015: Wrote it.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Mon Feb 24, 2020: Widened to 110 and added entry, exit, and stat announcements.
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory as its first
#                   argument, target as second, and regexp (instead of wildcard) as third.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and "Sys::Binmode".
# Sat Nov 27, 2021: Shortened sub names. Tested: Works.
# Thu Oct 03, 2024: Got rid of Sys::Binmode and common::sense; added "use utf8".
# Mon Mar 10, 2025: Got rid of given/when.
########################################################################################################################

use v5.32;
use utf8;

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
my $db = 1; # Set to 1 for debugging, 0 for no debugging.

# Program Settings:       Meaning:                 Range:    Defaults:
my $Recurse   = 0;      # Recurse subdirectories?  (bool)    0
my $Target    = 'F';    # Target                   F|D|B|A   'F'
my $Regexp    = '^.+$'; # Regular expression.      (regexp)  '^.+$'

# Counters:
my $direcount = 0; # Count of directories processed by curdire().
my $filecount = 0; # Count of directory entries matching target and regular expression.
my $corrcount = 0; # Count of corrupt files found.

# ======= MAIN BODY OF PROGRAM: ========================================================================================

{ # begin main
   argv;
   $Recurse and RecurseDirs {curdire} or curdire;
   stats;
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
            if ( $_ eq '-h' || $_ eq '--help'         ) {help; exit 777;}
         elsif ( $_ eq '-r' || $_ eq '--recurse'      ) {$Recurse =  1 ;}

         # Remove option from @ARGV:
         splice @ARGV, $i, 1;

         # Move the index 1-left, so that the "++$i" above
         # moves the index back to the current @ARGV element,
         # but with the new content which slid-in from the right
         # due to deletion of previous element contents:
         --$i;
      }
   }
   my $NA = scalar(@ARGV);
   if ( $NA > 1 ) {error($NA); help; exit(666);}
   if ( $NA > 0 ) {$Regexp = shift(@ARGV);}
   return 1;
} # end sub argv ()

sub curdire ()
{
   ++$direcount;
   my $curdir = cwd_utf8;
   say "\nDir # $direcount: $curdir\n";
   my $curdirfiles = GetFiles($curdir, $Target, $Regexp);
   foreach my $file (@{$curdirfiles})
   {
      curfile($file);
   }
   return 1;
} # end sub curdire ()

=pod

Corruption signature:
BB 1A E3 1E 3C 26 C2 62 57 E2 63 F3 27 4F 7C A3

=cut

sub curfile ($)
{
   ++$filecount;
   my $file = shift;
   return if not ($file->{Date} =~ m/^2014-10-/);
   my $fh;
   open($fh, '< :raw', e $file->{Path})
   or warn "Can't open  $file->{Path}\n" and return 1;
   my $buffer;
   read($fh, $buffer, 16, 0)
   or warn("Can't read  $file->{Path}\n") and close($fh) and return 1;
   close($fh);
   my $regex =
   qr/^\xBB\x1A\xE3\x1E\x3C\x26\xC2\x62\x57\xE2\x63\xF3\x27\x4F\x7C\xA3/;
   if ($buffer =~ m/$regex/)
   {
      ++$corrcount;
      say "CORRUPT: $file->{Path}";
   }
   return 1;
} # end sub curfile ($)

sub stats ()
{
   say "\nStats for program \"find-corrupt-files.pl\":";
   say "Navigated $direcount directories.";
   say "Examined  $filecount entries matching target \"$Target\" and regexp \"$Regexp\".";
   say "Found     $corrcount corrupt files.";
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

   Welcome to "find-corrupt-files.pl". This program searches for any files
   modified in October 2014 which contain the following as their first 16 bytes:
   BB 1A E3 1E 3C 26 C2 62 57 E2 63 F3 27 4F 7C A3
   This program will print the paths of all such files found.

   Command line:
   find-corrupt-files.pl [options] [argument]

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.
   "-r" or "--recurse"          Recurse subdirectories.
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
} # end sub help ()
