#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# merge-numbered-files.pl
# Merges two batches of numbered files in two given directories having same prefix, same suffix, and same number of
# digits. This program first renumbers files in the second batch as necessary so that the lowest second-batch number
# is 1 higher than the highest first-batch number; then it moves all files from the second-batch directory to the
# first-batch directory. This program does not delete or alter anything.
#
# This script is based-on and very-similar-to my earlier script titled "merge-batches" (now retired). But that script
# was intended to be used for Olympus digital camera JPG photos only, whereas this script is for general files;
# and that script deleted certain files and directories, whereas this script doesn't delete anything.
#
# Written by Robbie Hatley, starting Sunday February 07, 2016.
#
# Edit history:
#
# Sun Feb 07, 2016: Starting writing it as "merge-batches.pl".
# Sun Dec 26, 2017: Created this version, "merge-numbered-files.pl", and now using 5.026_001.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate.
# Sat Nov 20, 2021: Now using "v5.32", "common::sense", and "Sys::Binmode"
# Tue Nov 30, 2021: Fixed wide-character bug due to bad use of d and readdir in while loop (again!!!).
# Tue Nov 30, 2021: Fixed "finds no files" bug due to not coupling appropriate variable to m//. Tested: Now works.
# Sat Dec 04, 2021: Reformatted and corrected titlecard.
# Mon Mar 03, 2025: Got rid of "common::sense".
########################################################################################################################

use v5.32;
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS ==================================================================================

sub get_options_and_arguments;
sub process_options_and_arguments;
sub merge_numbered_files;
sub print_stats;
sub error_msg;
sub help_msg;

# ======= GLOBAL VARIABLES =============================================================================================

my $db        = 0  ; # Debug?
my @Arguments = () ; # Arguments.
my @Options   = () ; # Options.
my $Help      = 0  ; # Print help and exit?
my $prefix    = '' ; # Prefix.
my $digits    = 0  ; # Number of digits in each serial number.
my $suffix    = '' ; # Suffix.
my $dir1      = '' ; # Batch 1 directory.
my $dir2      = '' ; # Batch 2 directory.
my $dir1count = 0  ; # Count of files in first    batch.
my $dir2count = 0  ; # Count of files in second   batch.
my $bothcount = 0  ; # Count of files in combined batch.

# ======= MAIN BODY OF PROGRAM =========================================================================================
{
   print("\nNow entering program \"merge-numbered-files.pl\".\n\n");

   # Extract arguments and options from @ARGV
   # and store in @main::Arguments and @main::Options:
   get_options_and_arguments;

   # Interpret option and argument strings from command line
   # and set settings accordingly:
   process_options_and_arguments;

   # If user wants help, just print help and bail:
   if ($Help)
   {
      help_msg;
      exit 777;
   }

   # If number of arguments is out of range, bail:
   if ( 5 != @Arguments )
   {
      error_msg;
      exit 666;
   }

   # Merge batches:
   merge_numbered_files;

   # Print stats:
   print_stats;

   # We be done, so scram:
   print("\nNow exiting program \"merge-numbered-files.pl\".\n\n");
   exit 0;
} # end MAIN

# ======= SUBROUTINE DEFINITIONS =======================================================================================

sub get_options_and_arguments
{
   foreach (@ARGV)
   {
      if (/^-[\pL\pN]{1}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/) {push @Options,   $_;}
      else                                                 {push @Arguments, $_;}
   }
   return 1;
}

sub process_options_and_arguments
{
   foreach (@Options)
   {
      if ('-h' eq $_ || '--help' eq $_) {$Help = 1}
   }
   if (5 == @Arguments)
   {
      ($prefix, $digits, $suffix, $dir1, $dir2) = @Arguments[0, 1, 2, 3, 4];
   }
   if ($db)
   {
      say "In merge-numbered-files, in process_options_and_arguments.";
      say "\$prefix = $prefix";
      say "\$digits = $digits";
      say "\$suffix = $suffix";
      say "\$dir1   = $dir1  ";
      say "\$dir2   = $dir2  ";
   }
   return 1;
}

sub merge_numbered_files
{
   # Get lists of files matching $prefix, $digits, $suffix
   # in $dir1 and $dir2:
   my $dir1handle = undef             ; # Handle for directory 1.
   my $dir2handle = undef             ; # Handle for directory 2.
   my $name       = ''                ; # Name of a file.
   my $max1       = 0                 ; # Maximum batch 1 number.
   my $min2       = 0 + '9' x $digits ; # Minimum batch 2 number.
   my $boost      = 0                 ; # Boost.
   my $number     = 0                 ; # Number.
   my @numbers2   = ()                ; # List of numbers in directory 2.

   opendir($dir1handle, e $dir1) or die "Can't open dir \"$dir1\"\n$!\n";
   while ($name = d scalar readdir $dir1handle)
   {
      if ($db)
      {
         say '';
         say "In merge-numbered-files, in merge_numbered_files, in while 1.";
         say "Current name = \"$name\".";
      }
      next unless -f e path($dir1, $name);
      next unless $name =~ m/^$prefix\d{$digits}$suffix$/;
      $number = 0 + substr($name, length($prefix), $digits);
      $max1 = $number if $number > $max1;
      ++$dir1count;
      ++$bothcount;
   }
   closedir($dir1handle);

   opendir($dir2handle, e $dir2) or die "Can't open dir \"$dir2\"\n$!\n";
   while ($name = d scalar readdir $dir2handle)
   {
      if ($db)
      {
         say '';
         say "In merge-numbered-files, in merge_numbered_files, in while 2.";
         say "Current name = \"$name\".";
      }
      next unless -f e path($dir2, $name);
      next unless $name =~m/$prefix\d{$digits}$suffix$/;
      $number = 0 + substr($name, length($prefix), $digits);
      $min2 = $number if $number < $min2;
      push @numbers2, $number;
      ++$dir2count;
      ++$bothcount;
   }
   closedir($dir2handle);

   $boost = $max1 - $min2 + 1;

   say "\$max1  = $max1";
   say "\$min2  = $min2";
   say "\$boost = $boost";

   # Riffle backwards through all of the serial numbers used by
   # batch #2, renaming and moving the files in reverse order:
   for (reverse sort @numbers2)
   {
      my $oldname = sprintf "$dir2/$prefix%0${digits}d$suffix", $_;
      my $newname = sprintf "$dir1/$prefix%0${digits}d$suffix", $_ + $boost;
      say "$oldname => $newname";
      $newname eq $oldname and die "\nError: new name same as old!\n$!\n";
      rename(e($oldname), e($newname)) or die "\nError: rename failed!\n$!\n";
   }
   return 1;
} # end sub merge_numbered_files

sub print_stats
{
   print("\nStatistics for program \"merge-numbered-files.pl\":\n");
   say "Batch 1 contained     $dir1count files.";
   say "Batch 2 contained     $dir2count files.";
   say "Merged batch contains $bothcount files.";
   return 1;
} # end sub print_stats

sub error_msg
{
   print ((<<'   END_OF_ERROR') =~ s/^   //gmr);
   Error in "merge-files.pl": this program requires exactly 5 arguments:
   Arg1 = prefix
   Arg2 = digits
   Arg3 = suffix
   Arg4 = first  directory
   Arg5 = second directory
   For further help, type "merge-files.pl -h".
   END_OF_ERROR
   return 1;
} # end sub error_msg

sub help_msg
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "merge-files".   This program merges-together two batches of
   numbered files with same prefix, number of digits, and suffix.
   This program does any necessary number corrections to the files of the second
   batch, then moves the files of the second batch to the folder of the first
   batch.

   Command line:
   merge-batches [-h|--help] | [Arg1 Arg2 Arg3 Arg4 Arg5]

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.

   If not requesting help, this program takes 5 mandatory arguments:

   Arg 1: Prefix (all of the characters, if any, before the serial number).
   Arg 2: Number of digits in each file's serial number.
   Arg 3: Suffix (all of the characters, if any, after the serial number).
   Arg 4: First-batch directory.
   Arg 5: Second-batch directory.

   (NOTE: always enclose each argument in 'single quotes' or your shell may send
   the wrong arguments to this program.)

   This program will look for files with names matching the pattern you specify
   with Arguments 1, 2, 3 in the directories you specify in Arguments 4, 5.
   (To specify a file-name format lacking a prefix or suffix, set Arg 1 or Arg 2
   to '', the empty string.) This program  will then renumber the files of the
   second batch if necessary to assure that the lowest-numbered file in the
   second batch is 1 higher than the highest-numbered file in the first batch.
   Finally, it will then move the files of the second batch to the directory
   of the first batch.

   For example, to merge batches of files like these:

      batch 1: x8374 x8375 x8376 x8377 (in directory './dir1')
      batch 2: x8376 x8377 x8378 x8379 (in directory './dir2')

   the command line would look like:

      merge-batches 'x' '4' '' 'dir1' 'dir2'

   Merge-batches would then renumber the files of the second batch,
   increasing all of their numbers by 2 (to prevent name conflicts),
   then it will move the batch 2 files to the batch 1 directory
   (in this case, ./dir1).

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help_msg
