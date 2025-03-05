#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# for-each-file.pl
# Does some command for each file in current directory.
#
# Edit history:
# Mon May 04, 2015: Wrote first draft. STUB.
# Wed May 13, 2015: Changed Help to "Here Document" format. STUB.
# Thu Jun 11, 2015: Corrected a few minor issues. STUB.
# Fri Jul 17, 2015: Upgraded for utf8. Still a STUB.
# Sat Apr 16, 2016: Now using -CSDA. Also gave it some functionality. No longer a complete stub, but not
#                   yet ready for prime time. Still very buggy.
# Fri Jan 15, 2021: Refactored.
# Wed Feb 17, 2021: Now using the new GetFiles(), which now requires a fully-qualified directory as
#                   its first argument, target as second, and regexp (instead of wildcard) as third.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Sat Nov 27, 2021: Shortened sub names, fixed wide character error (due to missing e), and now printing each
#                   command line immediately before executing it. Tested: Works.
# Thu Oct 03, 2024: Got rid of Sys::Binmode and common::sense; added "use utf8".
# Mon Mar 03, 2025: Changed shebang to "#!/usr/bin/env -S perl -C63". Reduced width from 120 to 110.
#                   Increased min ver from "5.32" to "5.36" to get signatures. Removed all prototypes.
# Wed Mar 05, 2025: Consolidated changes from Glide and home. (Corrected help, etc.)
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

# Turn on debugging?
my $db = 0; # Set to 1 for debugging, 0 for no debugging.

#Program Settings:             Meaning:                 Range:     Default:
my $Recurse   = 0          ; # Recurse subdirectories?  (bool)     0
my $Target    = 'F'        ; # Target                   (F|D|B|A)  'F'

my $Regexp    = '.+'       ; # Regular expression.      (regexp)   '.+'
my $Command   = ''         ; # Command to be executed.  (string)   none

# Counters:
my $direcount = 0; # Count of directories processed by curdire().
my $filecount = 0; # Count of    files    processed by curfile().

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   say "\nNow entering \"for-each-file.pl\".\n";
   argv;
   $Recurse and RecurseDirs {curdire} or curdire;
   stats;
   say "\nNow exiting \"for-each-file.pl\".\n";
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub argv {
   my $help   = 0;  # Just print help and exit?
   my @CLArgs = (); # Command-Line Arguments (not including options).
   foreach (@ARGV)
   {
      if (/^-[\pL\pN]{1}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/)
      {
         /^-h$/ || /^--help$/         and $help    =  1 ;
         /^-r$/ || /^--recurse$/      and $Recurse =  1 ;
         /^-f$/ || /^--target=files$/ and $Target  = 'F'; # DEFAULT
         /^-d$/ || /^--target=dirs$/  and $Target  = 'D';
         /^-b$/ || /^--target=both$/  and $Target  = 'B';
         /^-a$/ || /^--target=all$/   and $Target  = 'A';

      }
      else {push @CLArgs, $_;}
   }
   if ($help) {help; exit 777;}           # If user wants help, print help and exit 777.
   my $NA = scalar @CLArgs;               # Get number of arguments.
   given ($NA)                            # Given the number of arguments,
   {
      when (0) {error($NA)             ;} # if $NA == 0, print error & help messages and exit 666;
      when (1) {$Command   = $CLArgs[0];} # if $NA == 1, set $Command;
      when (2) {$Command   = $CLArgs[0];
                $Regexp    = $CLArgs[1];} # if $NA == 2, set $Command and $Regexp;
      default  {error($NA)             ;} # if $NA  > 2, print error & help messages and exit 666.
   }
   return 1;
} # end sub argv

sub curdire {
   ++$direcount;
   my $curdir = cwd_utf8;
   say "\nDir # $direcount: $curdir\n";
   my $curdirfiles = GetFiles($curdir, $Target, $Regexp);
   foreach my $file (@{$curdirfiles})
   {
      curfile($file);
   }
   return 1;
} # end sub curdire

sub curfile ($file) {
   ++$filecount;
   say '';
   say      "$Command '$file->{Path}'";
   system e "$Command '$file->{Path}'";
   return 1;
} # end sub curfile

sub stats {
   print("\nStatistics for \"for-each-file.pl\":\n");
   say "Navigated $direcount directories.";
   say "Processed $filecount files.";
   return 1;
} # end sub stats

sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);
   Error: You typed $NA arguments, but this program takes 1 or 2 arguments.
   Argument 1 (mandatory) is a command to be executed on each file.
   Argument 2 (optional)  is a regular expression indicating which files.
   Help follows:

   END_OF_ERROR
   help;
   exit 666;
} # end sub error

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "for-each-file.pl", Robbie Hatley's nifty program for applying
   a command to each file in the current directory (and all subdirectories if
   a -r or --recurse option is used).

   Command lines:
   for-each-file.pl --help                      (to print this help and exit)
   for-each-file.pl [options] Command [regexp]  (to apply a command to files)

   Description of options:
   Option:           Meaning:
   "--help"          Print help and exit.
   "--recurse"       Recurse subdirectories. (Default is no recurse.)
   "--target=files"  Target files only. (DEFAULT)
   "--target=dirs"   Target directories only.
   "--target=both"   Target both files and directories.
   "--target=all"    Target everything (files, links, sockets, pipes...).

   In addition to options, "for-each-file.pl" takes 1 or 2 arguments:

   Argument 1 (mandatory) is a command to be executed on each file. The following
   command will be sent to the shell for each file being processed, where "Command"
   is the first argument to this program:

      Command 'FileName'

   The command can be any valid command that could be executed on a command line.
   Be sure to enclose your command in 'single quotes', else your shell may execute
   the command, whereas this program needs the raw command string sent to it.

   Argument 2 (optional), if present, must be a Perl-Compliant Regular Expression
   specifying which items to process. To specify multiple patterns, use the |
   alternation operator. To apply pattern modifier letters, use an Extended
   RegExp Sequence. For example, if you want to print the contents of any files
   with names containing "cat", "dog", or "horse", title-cased or not, you could
   use this command line:

      for-each-file.pl 'cat' '(?i:c)at|(?i:d)og|(?i:h)orse'

   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   If the number of arguments is not 1 or 2, this program will print an
   error message and abort.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
