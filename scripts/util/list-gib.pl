#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# list-gib.pl
# Lists files in which have wsl names.
#
# Edit history:
# Wed Nov 11, 2020: Wrote first draft.
# Fri Feb 26, 2021: Heavily refactored. Now fully functional.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and "Sys::Binmode".
# Mon Mar 03, 2025: Got rid of "common::sense" and "Sys::Binmode".
# Sat Apr 05, 2025: Now using "Cwd::utf8"; nixed "cwd_utf8".
########################################################################################################################

use v5.32;
use Cwd::utf8;

use RH::Util;
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =================================================================================

sub process_argv              ()  ;
sub process_current_directory ()  ;
sub stats                     ()  ;
sub help                      ()  ;

# ======= VARIABLES: ===================================================================================================

# Gibberish pattern:
my $gib      = qr(^[a-z]{8}(?:-\(\d{4}\))?(?:\.\w+)?$);

# Turn on debugging?
my $db = 0; # Set to 1 for debugging, 0 for no debugging.

#Program Settings:             Meaning:                 Range:     Default:
my $Recurse   = 0          ; # Recurse subdirectories?  (bool)     0

# Counters:
my $direcount = 0; # Count of directories processed.
my $gibfcount = 0; # Count of files with gibberish names.

# ======= MAIN BODY OF PROGRAM: ========================================================================================

{ # begin main
   process_argv();
   $Recurse and RecurseDirs {process_current_directory} or process_current_directory;
   stats;
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ======================================================================================

sub process_argv ()
{
   my $help = 0;  # Just print help and exit?
   my $i    = 0;  # Index for @ARGV.
   for ( $i = 0 ; $i < @ARGV ; ++$i )
   {
      $_ = $ARGV[$i];
      if (/^-[\pL\pN]{1}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/)
      {
         /^-h$/ || /^--help$/    and $help    = 1;
         /^-r$/ || /^--recurse$/ and $Recurse = 1;
         splice @ARGV, $i, 1; # Remove option from @ARGV.
         --$i; # Move index 1-left, so that the "++$i" above moves index back to current spot, with new item.
      }
   }
   if ($help) {help; exit 777;} # If user wants help, print help and exit 777.
   return 1;
} # end sub process_argv ()

sub process_current_directory ()
{
   ++$direcount;

   # Get and announce current working directory:
   my $cwd = cwd;
   say "\nDir # $direcount: $cwd\n";

   # Get list of paths of gib files in this dir:
   my @paths = glob_regexp_utf8($cwd, 'F', $gib);

   # List @paths:
   foreach my $path (@paths)
   {
      ++$gibfcount;
      say(get_name_from_path($path));
   }
   return 1;
} # end sub process_current_directory ()

sub stats ()
{
   say '';
   say "Statistics from \"list-gib.pl\":";
   say "Navigated $direcount directories.";
   say "Found $gibfcount gib files.";
   return 1;
} # end sub stats ()

sub help ()
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "list-gib.pl". This program lists all regular files in the current
   directory (and all subdirectories if a -r or --recurse option is used) which
   have gib names (names with roots consisting of 8 lower-case letters).

   Command line:
   list-gib.pl [options]

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.
   "-r" or "--recurse"          Recurse subdirectories (but not links).

   Any other options are ignored.

   Any non-option arguments are ignored.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help ()
