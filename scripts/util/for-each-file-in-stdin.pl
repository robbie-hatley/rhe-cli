#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# for-each-file-in-stdin.pl
# Performs a given BASH command (passed to this program as its first argument) once for each file path in a
# list of file paths passed to this program via stdin. Each time the command is executed, the token "FilePath"
# is set to the current file path. For example, the following will print all *.txt files in current directory:
# ls -1 *.txt | for-each-file-in-stdin.pl 'cat "FilePath"'
#
# Edit history:
# Sun Jul 21, 2024: Wrote it.
# Mon Jul 22, 2024: Improved error() and help().
# Thu Aug 15, 2024: -C63; improved comments and help().
# Wed Feb 26, 2025: Added missing "use utf8;".
##############################################################################################################

use v5.36;
use utf8;
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

# ======= VARIABLES: =========================================================================================

#Program Setting:    # Meaning:
my $Db        = 0  ; # Set to 1 for debugging, 0 for no debugging.
my $Command   = '' ; # Command to be executed.
my $Count     = 0  ; # Count of files processed.

# ======= MAIN BODY OF PROGRAM: ========================================================================================

{ # begin main
   say "\nNow entering \"for-each-file-in-stdin.pl\".\n";
   argv;
   say "\$Command = $Command" if $Db;

   foreach (<STDIN>) {
      my $FilePath = e($_);
      $FilePath =~ s/[\r\n]+$//;
      say "\$FilePath = \"$FilePath\"" if $Db;
      my $command  = $Command; # Capitalized version is template.
      $command =~ s/FilePath/$FilePath/g;
      say "\$command = \"$command\"" if $Db;
      system(e($command)); # DO encode here! (-C63 doesn't help with system calls.)
      ++$Count;
   }

   stats;
   say "\nNow exiting \"for-each-file-in-stdin.pl\".\n";
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ======================================================================================

sub argv {
   my $help   = 0;  # Just print help and exit?
   my @CLArgs = (); # Command-Line Arguments (not including options).
   foreach (@ARGV) {
      if (/^-[a-z]{1}$/ || /^--[a-z]{2,}$/) {
         /^-h$/ || /^--help$/ and $help    =  1 ;
      }
      else {push @CLArgs, $_;}
   }
   if ($help) {help(); exit 777;}     # If user wants help, print help and exit 777.
   my $NA = scalar @CLArgs;           # Get number of arguments.
   if (1 == $NA) {                    # If  number of arguments is 1,
      $Command = $CLArgs[0];          # that argument is our command.
   }
   else {                             # Otherwise that is an error,
      error($NA); help(); exit(666);  # so print error and help messages and exit.
   }
   return 1;
} # end sub argv

sub stats {
   print("\nStatistics for \"for-each-file-in-stdin.pl\":\n");
   say "Processed $Count files.";
   return 1;
} # end sub stats

sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: You typed $NA arguments, but this program must have exactly 1 argument
   which must be a valid BASH command using the token "FilePath" as a placeholder
   for each file-to-be-operated-on. Help follows.
   END_OF_ERROR
} # end sub error ($)

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Intro:
   Welcome to "for-each-file-in-stdin.pl", Robbie Hatley's nifty program for
   applying a given BASH command (given as the only command-line argument) to
   each file path given by a list of file paths fed into this program via STDIN.

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Command lines:

   1. To print this help and exit:
      for-each-file-in-stdin.pl [-h|--help]

   2. To apply Command to file paths given by a "generator" program:
      generator | for-each-file-in-stdin.pl Command
      (where "generator" is a command that generates a list of file paths)

   3. To apply Command to file paths from an existing list:
      for-each-file-in-stdin.pl Command < pathlist
      (where "pathlist" is a file containing file paths, one-per-line)

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Description of options:
   Option:             Meaning:
   "-h" or "--help"    Print this help and exit.

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Description of argument:
   Unless just asking for help, "for-each-file-in-stdin.pl" takes exactly 1
   argument, which must be a valid BASH command which does something to a file
   called "FilePath". This command will be executed once for each file path given
   in stdin. For each file path in stdin, the token "FilePath" in the command
   will be set to the path of that file. Be sure to enclose the argument in
   'single quotes' (so that it gets passed verbatim to this program), and be
   sure to enclose the token "FilePath" in "double quotes" (so that file names
   with spaces won't cause errors).

   For example, to print the contents of all files in the current directory,
   you could type this:

      ls -1 | for-each-file-in-stdin.pl 'cat "FilePath"'

   If the number of arguments is not exactly 1, this program will print an
   error message and abort.

   Also note that this program will malfunction if the command given by the
   argument is not a valid BASH command, so make sure the argument is a valid
   BASH command which does something useful to file "FilePath".

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
