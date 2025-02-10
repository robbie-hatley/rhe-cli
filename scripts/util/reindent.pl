#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# reindent.pl
# Usage: "rindent.pl p1 p2 regexp"
# Reformats files from multiple-of-p1 indentation to multiple-of-p2 indentation.
#
# Author: Robbie Hatley
#
# Edit history:
# Mon Nov 01, 2021: Wrote it.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and "Sys::Binmode".
# Mon Jun 05, 2023: Renamed from "p1-to-p2.pl" (cryptic!) to "reindent.pl".
########################################################################################################################

use v5.32;
use common::sense;
use Time::HiRes 'time';
use POSIX 'floor', 'ceil';
use RH::Util;
use RH::WinChomp;
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

#Program Settings:                 Meaning:                  Range:    Default:
my $Recurse   = 0              ; # Recurse subdirectories?   bool      0
my $Target    = 'F'            ; # Target                    F|D|B|A   'A'
my $RegExp    = qr/^.+\.lsl$/o ; # Regular expressions.      regexp    '^.+\.lsl$' (over-ride-able by argv())
my $p1        = 4              ; # Period 1.                 pos int   4
my $p2        = 3              ; # Period 2.                 pos int   3

# Counters:
my $direcount = 0; # Count of directories processed by curdire().
my $filecount = 0; # Count of dir entries processed by curfile().
my $succcount = 0; # Count of files successfully reformatted.
my $failcount = 0; # Count of failed reformat attempts.

# ======= MAIN BODY OF PROGRAM: ========================================================================================

{ # begin main
   say "Now entering program \"" . get_name_from_path($0) . "\".";
   my $t0 = time;
   argv();
   say "Recurse = $Recurse";
   say "Target  = $Target";
   say "P1      = $p1";
   say "P2      = $p2";
   say "RegExp  = $RegExp";
   $Recurse and RecurseDirs {curdire} or curdire;
   stats;
   my $µs = 1000000 * (time - $t0);
   printf("\nNow exiting program \"%s\". Execution time was %.3fµs.\n", get_name_from_path($0), $µs);
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
         if (/^-h$/ || /^--help$/        ) {help; exit 777;}
         if (/^-r$/ || /^--recurse$/     ) {$Recurse =  1 ;}

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
   given ($NA)
   {
      when (2)
      {
         $p1=$ARGV[0];            # Set Period 1.
         $p2=$ARGV[1];            # Set Period 2.
      }
      when (3)
      {
         $p1=$ARGV[0];            # Set Period 1.
         $p2=$ARGV[1];            # Set Period 2.
         $RegExp = qr/$ARGV[2]/o; # Set $RegExp.
      }
      default
      {
         error($NA);              # Print error and help messages and exit 666.
      }
   }
   return 1;

} # end sub argv ()

sub curdire ()
{
   # Increment directory counter:
   ++$direcount;

   # Get and announce current working directory:
   my $cwd = cwd_utf8;
   say "\nDirectory # $direcount: $cwd\n";

   # Get list of file-info packets in $cwd matching $Target and $RegExp:
   my $curdirfiles = GetFiles($cwd, $Target, $RegExp);

   # Iterate through $curdirfiles and send each file to curfile():
   foreach my $file (@{$curdirfiles})
   {
      curfile($file);
   }
   return 1;
} # end sub curdire ()

sub curfile ($)
{
   my $file  = shift;
   my $path  = $file->{Path};
   my $name  = get_name_from_path($path);
   my $pref  = get_prefix($name);
   my $suff  = get_suffix($name);
   my $h     = undef;
   my @lines = ();

   # Increment global file counter:
   ++$filecount;

   # Get name, prefix, and suffix:
   $name = get_name_from_path($path);

   # Grab file contents:
   $h = undef;
   if (not open_utf8($h, '<', $path))
   {
      say("Failed to open $path for reading.");
      ++$failcount;
      return 0;
   }
   @lines = <$h>;
   close($h);

   # Convert leading spaces from x4 to x3:
   for (@lines)
   {
      winchomp;
      s/^( +)(?=[^ ])/" " x ($p2 * ceil(length($1) \/ $p1))/e;
   }

   # Write $lines to a new file:
   $h=undef;
   if (open_utf8($h, '>', $path))
   {
      for (@lines)
      {
         say($h $_);
      }
      close($h);
      say("Successfully reformatted $path");
      ++$succcount;
      return 1;
   }
   else
   {
      say("Failed to open $path for writing.");
      ++$failcount;
      return 0;
   }
} # end sub curfile ($)

sub stats ()
{
   say '';
   say 'Statistics for this directory tree:';
   say "Navigated $direcount directories.";
   say "Processed $filecount files.";
   say "Successfully reformated $succcount files.";
   say "Failed $failcount reformat attempts.";
   return 1;
} # end sub stats ()

sub error ($)
{
   my $NA = shift;
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);
   Error: you typed $NA arguments, but this program takes 2 or 3 arguments.
   Help follows:

   END_OF_ERROR
   help;
   exit 666;
} # end sub error ($)

sub help ()
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "reindent.pl". This program converts space-based indenting of
   files (lsl scripts by default, but this can be changed with regexps)
   from "multiples-of-p1" to "multiples-of-p2". This program effects all
   targeted files in the current directory, and all subdirectories as well
   if a -r or --recurse option is used.

   Command lines:
   reindent.pl   -h | --help             (to print help and exit)
   reindent.pl   [options] [arguments]   (to [perform funciton] )

   Options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.
   "-r" or "--recurse"          Recurse subdirectories.

   Mandatory arguments:

   The first  argument must be the space period of the existing indenting.
   (Eg: 4, meaning multiples of 4 spaces.)

   The second argument must be the space period of the desired indenting.
   (Eg: 3, meaning multiples of 3 spaces.)

   Optional arguments:

   This program can take an optional 3rd argument which, if present, must be a
   Perl-Compliant Regular Expression specifying which items to process.
   To specify multiple patterns, use the | alternation operator.
   To apply pattern modifier letters, use an Extended RegExp Sequence.
   For example, if you want to search for items with names containing "cat",
   "dog", or "horse", title-cased or not, you could use this regexp:
   '(?i:c)at|(?i:d)og|(?i:h)orse'
   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   Happy script reformatting!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help ()
