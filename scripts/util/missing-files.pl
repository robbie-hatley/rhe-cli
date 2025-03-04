#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# missing-files.pl
# Determines which files are missing from a numbered sequence of files.
# Input is 3 command-line arguments: NameSignature, FirstNumber, LastNumber
#
# Edit history:
# Thu Jul 23, 2015: Wrote it.
# Fri Jul 24, 2015: Minor corrections.
# Sat Apr 16, 2016: Now using -CSDA.
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory as
#                   its first argument, target as second, and regexp (instead of wildcard) as third.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and "Sys::Binmode".
# Mon Mar 03, 2025: Got rid of "common::sense" and "Sys::Binmode".
########################################################################################################################

use v5.32;
use RH::Util;
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS ==================================================================================

sub get_options_and_arguments;
sub process_options_and_arguments;
sub find_missing_files;
sub get_root;
sub get_numb;
sub error_msg;
sub help_msg;

# ======= GLOBAL VARIABLES =============================================================================================

our @Arguments;
our @Options;
our $Help   =  0;               # Print help and exit?
our $Root   =  'abcd####.jpg';  # File name root.
our $First  =    1;             # First number in sequence.
our $Last   =  100;             # Last  number in sequence.

# ======= MAIN BODY OF PROGRAM =========================================================================================
{
   # Extract arguments and options from @ARGV and store in
   # @main::Arguments and @main::Options:
   get_options_and_arguments;

   # Interpret option and argument strings from command line
   # and set settings accordingly:
   process_options_and_arguments;

   say "Root  = $Root";
   say "First = $First";
   say "Last  = $Last";

   # Find missing files:
   find_missing_files;

   # We be done, so scram:
   exit 0;
} # end MAIN

# ======= SUBROUTINE DEFINITIONS =======================================================================================

sub get_options_and_arguments
{
   foreach (@ARGV)
   {
      if (/^-[\pL\pN]{1}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/)
      {
         if ($_ eq '-h' || $_ eq '--help') {push(@Options, $_);}
      }
      else
      {
         push(@Arguments, $_);
      }
   }
   return 1;
} # end sub get_options_and_arguments

sub process_options_and_arguments
{
   foreach (@Options)
   {
      if ('-h' eq $_ || '--help' eq $_) {$Help = 1;}
   }

   # If user wants help, just print help and bail:
   if ($Help)
   {
      help_msg;
      exit 777;
   }

   # If number of arguments is out of range, bail:
   if ( @Arguments != 3 )
   {
      error_msg;
   }
   $Root  = $Arguments[0];
   $First = $Arguments[1];
   $Last  = $Arguments[2];
   return 1;
} # end sub process_options_and_arguments

sub find_missing_files
{
   # Get current directory:
   my $curdir = cwd_utf8;

   # Get list of all regular files in current directory:
   my $curdirfiles = GetFiles($curdir, 'F');

   # Make array to hold file names matching root:
   my @matching_names;

   # Get names matching $Root in the range $First through $Last:
   foreach my $file (@{$curdirfiles})
   {
      if
      (
         get_root($file->{Name}) eq $Root
         &&
         get_numb($file->{Name}) >= $First
         &&
         get_numb($file->{Name}) <= $Last
      )
      {
         push @matching_names, $file->{Name};
      }
   }

   # Now, how about a sorted version of that?
   my @sorted_names = sort @matching_names;

   # Start with $previous and $current set to $First - 1 :
   my $prev_num = $First - 1;
   my $curr_num = $First - 1;

   # For each existing file, print numbers of any non-existent
   # files in the range (PreviousFile,CurrentFile) :
   foreach my $name (@sorted_names)
   {
      $curr_num = get_numb($name);
      foreach my $num ( $prev_num + 1 .. $curr_num - 1 )
      {
         say $num;
      }
      $prev_num = $curr_num;
   }

   # Finally, print numbers of all files after final existing file
   # up to and including $Last:
   foreach my $num ($curr_num + 1 .. $Last ) {say $num;}
   return 1;
} # end sub find_missing_files

sub get_root
{
   my $filename = shift;
   $filename =~ s/\d/#/g;
   return $filename;
} # end sub get_root

sub get_numb
{
   my $filename = shift;
   $filename =~ s/\D//g;
   return $filename;
} # end sub get_numb

sub error_msg
{
   say 'Error: This program takes exactly 3 arguments, which must be:';
   say '1. file name root (file name with digits replaced by octothorpes)';
   say '2. first number';
   say '3. last number';
   say 'Help follows:';
   help_msg;
   exit 666;
} # end sub error_msg

sub help_msg
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "missing-files.pl", Robbie Hatley's nifty program for determining
   which (if any) files are missing from a numbered set of files, such as:
   "BritSprsNud001.jpg", "BritSprsNud002.jpg", "BritSprsNud003.jpg", etc.

   Command line to just get help and exit:
   missing-files.pl [-h|--help]

   Command line to find which files are missing from a sequence:
   missing-files.pl 'FileNameRoot' FirstNumber LastNumber

   FileNameRoot must be the name of one of the files in the series with the digits
   replaced by octothorpes ('#').

   FirstNumber must be the first number of the series.

   LastNumber must be the last number of the series.

   Missing-Files will then print a list of all the file names with the given root
   name, in the given range, which do NOT actually exist in the current directory.

   Example: If you have a series of files which should span from "Naughty0001.jpg"
   through "Naughty0397.jpg", then the following should print the names of any
   files in the series which do NOT actually exist in your current directory:

   missing-files.pl 'Naughty####.jpg' 1 397

   To prevent confusing the shell, the file name root should be enclosed in
   'single quotes'. It's not necessary to do this for the numbers, though.

   The digits of the file names don't have to be contiguous  However, if they're
   not, then the results of running missing-files can be surprising, because all
   the digits are run together in the program to get the number of a file.
   For example, the number of file "cat37-035.jpg" is 37035.  Therefore,
   if subseries 37 runs from 1 to 87 and subseries 38 runs from 1 to 275, then
   missing-files will report 913 missing files between "cat37-087.jpg" and
   "cat38-001.jpg", even though there are really ZERO missing files. Hence in
   cases like this, it's best to run missing-files separately for each subseries.

   Also note that my 2015 Perl version of this program is fully Unicode-compliant,
   so file names such as "茶色の猫3872.jpg" are perfectly fine.
   ("茶色の猫" is pronounced "cha iro no neko" and is Japanese for "brown cat".
   Literally, the characters mean "tea color describes cat".)

   Also note that this program works in the current directory only;
   no recursive descent of directories is available at this time
   (though I may add this feature later if it seems useful).

   Also note that this program works on "regular" files only, not
   links, directories, etc.

   Also note that this program will not work on file names beginning
   with a dot.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
}
