#!/usr/bin/env perl

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# list-wsl.pl
# Lists files in which have wsl names.
#
# Edit history:
# Wed Nov 11, 2020: Wrote first draft.
# Fri Feb 26, 2021: Heavily refactored. Now fully functional.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Mon Mar 03, 2025: Got rid of "common::sense" and "Sys::Binmode".
# Sat Apr 05, 2025: Now using "Cwd::utf8"; nixed "cwd_utf8".
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e". Nixed prototypes. Min ver "5.32" -> "5.36". Now using signatures.
#                   Reduced width from 120 to 110.
##############################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub stats   ; # Print statistics.
sub help    ; # Print help and exit.

# ======= VARIABLES: =========================================================================================

# Windows SpotLight pattern:
my $wsl  = qr(^[0-9a-f]{64}(?:-\(\d{4}\))?(?:\.\w+)?$);

# Turn on debugging?
my $db = 0; # Set to 1 for debugging, 0 for no debugging.

#Program Settings:             Meaning:                 Range:     Default:
my $Recurse   = 0          ; # Recurse subdirectories?  (bool)     0

# Counters:
my $direcount = 0; # Count of directories processed.
my $wslfcount = 0; # Count of files with wsl names.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   argv;
   $Recurse and RecurseDirs {curdire} or curdire;
   stats;
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub argv {
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
} # end sub argv

sub curdire {
   ++$direcount;

   # Get and announce current working directory:
   my $cwd = cwd;
   say "\nDir # $direcount: $cwd\n";

   # Get list of paths of wsl files in this dir:
   my @paths = glob_regexp_utf8($cwd, 'F', $wsl);

   # List @paths:
   foreach my $path (@paths)
   {
      ++$wslfcount;
      say(get_name_from_path($path));
   }
   return 1;
} # end sub curdire

sub stats {
   say '';
   say "Statistics from \"list-wsl.pl\":";
   say "Navigated $direcount directories.";
   say "Found $wslfcount wsl files.";
   return 1;
} # end sub stats

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "list-wsl.pl". This program lists all regular files in the current
   directory (and all subdirectories if a -r or --recurse option is used) which
   have wsl names (names with roots consisting of 64-digit hexadecimal numbers).

   Command line:
   list-wsl.pl [options]

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
} # end sub help
