#!/usr/bin/perl

# This is an 120-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# /rhe/scripts/util/rhdir
# Prints information about every file in current working directory.
# Edit history:
#    ??? ??? ??, 20?? - Wrote it.
#    Fri Jul 17, 2015 - Upgraded for utf8.
########################################################################################################################

use v5.32;
use strict;
use warnings;

use utf8::all;
use Cwd::utf8;

use RH::Util;
use RH::Dir;


# ======= SUBROUTINE PRE-DECLARATIONS ==================================================================================

sub get_options_and_arguments;
sub process_options_and_arguments;
sub process_current_directory;
sub print_stats;
sub error_msg;
sub help_msg;

# ======= GLOBAL VARIABLES =============================================================================================

our @Options;
our @Arguments;
our %Settings = (             # Meaning of setting:               Possible values:
   Help         => 0,         # Print help and exit?              (bool)
   Recurse      => 0,         # Recurse subdirectories?           (bool)
   Target       => 'A',       # Target                            F|D|B|A
   Regexp       => '.+',      # Regular expression.               (regexp)
   Verbose      => 0,         # List files by type?               (bool)
);

# Main:: accumulations of counters from RH::Dir :
our $totfcount = 0; # Count of all "files" (directory entities) seen, of all types.
our $regfcount = 0; # Count of all regular files seen.
our $sdircount = 0; # Count of all immediate subdirectories of current directory found.
our $linkcount = 0; # Count of all non-dir links found.
our $slkdcount = 0; # Count of all SIMLINKD objects found.
our $pipecount = 0; # Count of all pipes found.
our $sockcount = 0; # Count of all sockets found.
our $bspccount = 0; # Count of all block special files found.
our $cspccount = 0; # Count of all character special files found.
our $ottycount = 0; # Count of all tty files found.
our $unkncount = 0; # Count of all unknown files found.


# Main:: accumulations of events in Main:: only:
our $direcount = 0; # Count of directories processed.

# ======= MAIN BODY OF PROGRAM =========================================================================================

MAIN:
{
   # Extract arguments and options from @ARGV and store in @main::Arguments and @main::Options:
   get_options_and_arguments;

   # Interpret option and argument strings from command line and set settings accordingly:
   process_options_and_arguments;

   # If user wants help, just print help and bail:
   if ($Settings{Help})
   {
      help_msg;
      exit 777; # User requested help.
   }

   # If number of arguments is out of range, bail:
   if (@Arguments > 1)
   {
      error_msg;
      exit 666; # Something evil happened!
   }

   # If user asked for recursion, recurse subdirectories:
   if ($Settings{Recurse})
   {
      RecurseDirs(\&process_current_directory);
   }

   # Otherwise, process current directory only (default):
   else
   {
      process_current_directory;
   }

   # Print stats:
   print_stats;

   # We be done, so scram:
   exit 0;
} # end MAIN

# ======= SUBROUTINE DEFINITIONS =======================================================================================

sub get_options_and_arguments
{
   foreach (@ARGV)
   {
      if ('-' eq substr($_,0,1))
      {
         push(@Options, $_);
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
      if ('-h' eq $_ || '--help'         eq $_) {$Settings{Help}    =  1 ;} # Default is 0.
      if ('-r' eq $_ || '--recurse'      eq $_) {$Settings{Recurse} =  1 ;} # Default is 0.
      if ('-f' eq $_ || '--target=files' eq $_) {$Settings{Target}  = 'F';} # Default is 'A'.
      if ('-d' eq $_ || '--target=dirs'  eq $_) {$Settings{Target}  = 'D';} # Default is 'A'.
      if ('-b' eq $_ || '--target=both'  eq $_) {$Settings{Target}  = 'B';} # Default is 'A'.
      if ('-a' eq $_ || '--target=all'   eq $_) {$Settings{Target}  = 'A';} # Default is 'A'.
      if ('-v' eq $_ || '--verbose'      eq $_) {$Settings{Verbose} =  1 ;} # Default is 0.
   }
   if (@Arguments >= 1) {$Settings{Regexp} = $Arguments[0];}
   return 1;
} # end sub process_options_and_arguments

sub process_current_directory
{
   # Were's starting to process a directory, so increment $dircount:
   ++$direcount;

   # Get and announce current working directory:
   my $curdir = cwd_utf8;
   say '';
   say '';
   say "Directory # $direcount:";
   say $curdir;

   # Get list of targeted files in current directory:
   my $records = GetFiles($curdir, $Settings{Target}, $Settings{Regexp});

   # Append counts of total and regular files from RH::Dir:: to main:: :
   $totfcount += $RH::Dir::totfcount; # Count of all "files" (directory entities) seen, of all types.
   $regfcount += $RH::Dir::regfcount; # Count of all regular files seen.
   $sdircount += $RH::Dir::sdircount; # Count of all immediate subdirectories of current directory found.
   $linkcount += $RH::Dir::linkcount; # Count of all non-dir links found.
   $slkdcount += $RH::Dir::slkdcount; # Count of all SIMLINKD objects found.
   $pipecount += $RH::Dir::pipecount; # Count of all pipes found.
   $sockcount += $RH::Dir::sockcount; # Count of all sockets found.
   $bspccount += $RH::Dir::bspccount; # Count of all block special files found.
   $cspccount += $RH::Dir::cspccount; # Count of all character special files found.
   $ottycount += $RH::Dir::ottycount; # Count of all tty files found.
   $unkncount += $RH::Dir::unkncount; # Count of all unknown files found.

   # Make array to hold re-ordered list of files:
   my @files;

   foreach my $record (@{$records})
   {
      if ('D' eq $record->{Type})
      {
         push @files, $record;
      }
   }

   foreach my $record (@{$records})
   {
      if ('S' eq $record->{Type})
      {
         push @files, $record;
      }
   }

   foreach my $record (@{$records})
   {
      if ('L' eq $record->{Type})
      {
         push @files, $record;
      }
   }

   foreach my $record (@{$records})
   {
      if ('F' eq $record->{Type})
      {
         push @files, $record;
         system("cat '$record->{Name}'");
      }
   }

   foreach my $record (@{$records})
   {
      if ('P' eq $record->{Type})
      {
         push @files, $record;
      }
   }

   foreach my $record (@{$records})
   {
      if ('O' eq $record->{Type})
      {
         push @files, $record;
      }
   }

   foreach my $record (@{$records})
   {
      if ('X' eq $record->{Type})
      {
         push @files, $record;
      }
   }

   foreach my $record (@{$records})
   {
      if ('Y' eq $record->{Type})
      {
         push @files, $record;
      }
   }

   foreach my $record (@{$records})
   {
      if ('T' eq $record->{Type})
      {
         push @files, $record;
      }
   }

   foreach my $record (@{$records})
   {
      if ('U' eq $record->{Type})
      {
         push @files, $record;
      }
   }

   say 'T: Date:       Time:        Size:     Name:';

   foreach my $file (@files)
   {
      printf("%1s  %-10s  %-11s  %8.2E  %s\n",
      $file->{Type}, $file->{Date}, $file->{Time}, $file->{Size}, $file->{Name});
   }
   return 1;
} # end sub process_current_directory

sub print_stats
{
   say '';
   say "Navigated $direcount directories.";
   say "Encountered $totfcount files.";
   if ($Settings{Verbose})
   {
      say 'Files encountered included:';
      printf("%7d  regular files\n", $regfcount);
      printf("%7d  non-link directories\n", $sdircount);
      printf("%7d  non-directory links\n", $linkcount);
      printf("%7d  SYMLINKDs\n", $slkdcount);
      printf("%7d  pipes\n", $pipecount);
      printf("%7d  sockets\n", $sockcount);
      printf("%7d  block special files\n", $bspccount);
      printf("%7d  character special files\n", $cspccount);
      printf("%7d  tty files\n", $ottycount);
      printf("%7d  files of unknown type\n", $unkncount);
   }
   return 1;
} # end sub print_stats

sub error_msg
{
   say 'Error: Template takes at most 1 argument, which (if present) must be';
   say 'a regular expression specifying which directories and/or files to process.';
   return 1;
} # end sub error_msg

sub help_msg
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "utf8-all-test.pl", Robbie Hatley's Nifty tester for the
   CPAN module "UTF

   Command line:
   template.pl [-h|--help] [-r|--recurse] [Arg1]

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.
   "-r" or "--recurse"          Recurse subdirectories (but not links).
   "-d" or "--target=dirs"      Rename directories only.
   "-b" or "--target=both"      Rename both files and directories.
   "-a" or "--target=all"       Rename files, directories, and symlinks.
   "-v" or "--verbose"          Be verbose.

   In addition to options, Template can take one optional argument which, if
   if present, must be a regular expression specifying which files and/or
   directories to process.

   Happy testing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help_msg
