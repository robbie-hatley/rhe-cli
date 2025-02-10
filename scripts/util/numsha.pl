#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# numsha.pl
# Prints number of sha1 file names in current directory (and all subdirectories if "-r" or "--recurse" is used).
#
# Author: Robbie Hatley
#
# Edit history:
# Fri Jun 18, 2021: Wrote it.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and "Sys::Binmode".
# Wed Nov 24, 2021: Refactored. Now using a regexp instead of wildcard, and tested in harsh UTF-8 environment. Works.
########################################################################################################################

use v5.32;
use common::sense;
use Time::HiRes 'time';

use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =================================================================================

sub argv    ()  ;
sub curdire ()  ;
sub curfile ($) ;
sub stats   ()  ;
sub error   ($) ;
sub help    ()  ;

# ======= VARIABLES: ===================================================================================================

# Turn on debugging?
my $db = 0; # Set to 1 for debugging, 0 for no debugging.

#Program Settings:             Meaning:                 Range:     Default:
my $Recurse   = 0          ; # Recurse subdirectories?  (bool)     0
my $Target    = 'F'        ; # Target.                  (F|D|B|A)  'F'
my $Regexp    = '^.+$'     ; # Regexp.                  (regexp)   '^.+$'

# Counters:
my $direcount = 0; # Count of directories processed by curdire().
my $filecount = 0; # Count of dir entries processed by curfile().
my $sha1count = 0; # Count of sha1 file names found.

# Regexps:
my $Sha1Pat = qr(^[0-9a-f]{40}(?:-\(\d{4}\))?(?:\.[a-zA-Z]+)?$);

# ======= MAIN BODY OF PROGRAM: ========================================================================================

{ # begin main
   say "\nNow entering program \"" . get_name_from_path($0) . "\".";
   my $t0 = time;
   argv();
   say "Recurse  = $Recurse";
   say "Target   = $Target";
   say "Regexp   = $Regexp";
   $Recurse and RecurseDirs {curdire} or curdire;
   stats;
   my $t1 = time; my $te = $t1 - $t0;
   say "\nNow exiting program \"" . get_name_from_path($0) . "\". Execution time was $te seconds.";
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
         if (/^-r$/ || /^--recurse$/     ) {$Recurse =  1 ;} # Default is 0.
         if (/^-f$/ || /^--target=files$/) {$Target  = 'F';} # Default is 'F'.
         if (/^-d$/ || /^--target=dirs$/ ) {$Target  = 'D';} # Default is 'F'.
         if (/^-b$/ || /^--target=both$/ ) {$Target  = 'B';} # Default is 'F'.
         if (/^-a$/ || /^--target=all$/  ) {$Target  = 'A';} # Default is 'F'.
         splice @ARGV, $i, 1; # Remove option from @ARGV.
         --$i; # Move index 1-left, so that the "++$i" above moves
               # the index back to current spot, with new item.
      }
   }
   my $NA = scalar(@ARGV);
   given ($NA)
   {
      when (0)
      {
         ; # Do nothing.
      }
      when (1)
      {
         $Regexp = qr/$ARGV[0]/;
      }
      default
      {
         error($NA);
      }
   }
   return 1;
} # end sub argv ()

sub curdire ()
{
   ++$direcount;

   # Get and announce current working directory:
   my $curdir = cwd_utf8;
   say "\nDir # $direcount: $curdir\n";

   # Get ref to array of file-record hashes of of directory entries matching target and regexp:
   my $CurDirFiles = GetFiles($curdir, $Target, $Regexp);

   # Iterate through files, sending each to curfile():
   foreach my $file (@{$CurDirFiles})
   {
      curfile($file);
   }
   return 1;
} # end sub curdire ()

sub curfile ($)
{
   ++$filecount;
   my $file = shift;
   if ($file->{Name} =~ m/$Sha1Pat/)
   {
      ++$sha1count;
      say "SHA1: \"$file->{Name}\"";
   }
   return 1;
} # end sub curfile ($)

sub stats ()
{
   say "\nNavigated $direcount directories.";
   say "Found $filecount files, $sha1count with SHA1 names.";
   return 1;
} # end sub stats ()

sub error ($)
{
   my $NA = shift;
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);
   Error: \"synchronize.pl\" takes 1 optional argument which, if present, must be
   a regular expression specifying which directory entries to process; but you
   entered $NA arguments. Help follows.

   END_OF_ERROR
   help;
   exit(666);
} # end sub error ($)

sub help ()
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "numsha.pl". This program prints the number of sha1 file names
   in the current directory (and all subdirectories if a "-r" or "--recurse"
   option is used).

   Command lines:
   numsha.pl -h | --help            (to print this help and exit)
   numsha.pl [options] [arguments]  (to print number of sha1 names)

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.
   "-r" or "--recurse"          Recurse subdirectories (but not links).
   "-f" or "--target=files"     Target files only.
   "-d" or "--target=dirs"      Target directories only.
   "-b" or "--target=both"      Target both files and directories.
   "-a" or "--target=all"       Target all (files, directories, symlinks, etc).

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
