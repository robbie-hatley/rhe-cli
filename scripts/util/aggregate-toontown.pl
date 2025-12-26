#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# aggregate-toontown.pl
# Aggregates TTR screenshots from my two TTR program screenshots folders to a folder in my Arcade.
#
# Edit history:
# Thu Oct 29, 2020: Wrote it.
# Sat Jan 02, 2021: Refactored to use my new "move-files.pl" script.
# Sun Jan 03, 2021: Sub "move-file" in RH::Dir now uses system(mv), so cross-system moving actually does
#                   work now. Also, simplified dir names, and now moving to 2021 instead of 2020.
# Fri Jan 29, 2021: Now also renames and files-away screenshots in appropriate year/month directories.
# Sat Feb 13, 2021: Simplified. Now an ASCII file. No-longer uses -CSDA. Runs on all Perl versions.
# Sat Jul 31, 2021: File is now UTF-8, 120 characters wide. Now using "use utf8", "use Sys::Binmode", and "e".
# Wed Oct 27, 2021: Added Help() function.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate. Now using "common::sense".
# Thu Nov 25, 2021: Fixed regexp bug that was causing program to find no files. Added timestamping.
# Fri Nov 26, 2021: Fixed yet another regexp bug (program was refusing to file files by date).
# Thu Aug 17, 2023: Reduced width from 120 to 110. Upgraded from "V5.32" to "v5.36". Got rid of CPAN module
#                   "common::sense" (antiquated). Got rid of prototypes. Program is very broken, though,
#                   because it's trying to use directories which don't exist. TO-DO: Fix dirs.
# Sat Aug 19, 2023: Fixed directories and returned full multi-platform functionality.
# Thu Aug 24, 2023: Got rid of "/...|.../" in favor of "/.../ || /.../" (speeds-up program).
# Fri Aug 25, 2023: Now calls "rename-toontown-images.pl" in "verbose" mode.
#                   Now expressing execution time in seconds, to nearest millisecond.
# Mon Aug 28, 2023: Changed all "$db" to "$Db". Now using "d getcwd" instead of "cwd_utf8".
# Wed Aug 14, 2024: Removed unnecessary "use" statements.
# Wed Feb 26, 2025: Trimmed one horizontal divider.
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e", and now using "cwd" instead of "d getcwd".
# Mon May 05, 2025: Reverted to using "#!/usr/bin/env -S perl -C63" shebang and "utf8" instead of "utf8::all"
#                   and "Cwd" instead of "Cwd::utf8", for Cygwin compatibility. Fixed no-mk-yr-dir bug.
# Fri Dec 26, 2025: Re-reverted to "#!/usr/bin/env perl", "use utf8::all", "use Cwd::utf8".
#                   Moved from "core" to "util". Deleted "core".
##############################################################################################################

# ======= PRELIMINARIES: =====================================================================================

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv;
sub aggregate;
sub help;

# ======= VARIABLES: =========================================================================================

# Settings:
my $Db = 0;
my $image_regexp = qr/\.jpg$|\.png$/io;
my $program_dir_1   = 'not_set';
my $program_dir_2   = 'not_set';
my $screenshots_dir = 'not_set';
my $platform = $ENV{PLATFORM};

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   my $t0 = time;
   argv;
   say    'Now entering program "aggregate-toontown.pl".';
   say    "\$Db              = $Db";
   say    "\$image_regexp    = $image_regexp";
   say    "\$program_dir_1   = $program_dir_1";
   say    "\$program_dir_2   = $program_dir_2";
   say    "\$screenshots_dir = $screenshots_dir";
   say    "\$Platform        = \"$platform\".";

   aggregate;

   my $et = time - $t0;
   say    '';
   say    'Now exiting program "aggregate-toontown.pl".';
   printf "Execution time was %.3f seconds.\n", $et;
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV :
sub argv {
   for ( @ARGV ) {
      if    ( /^-h$/ || /^--help$/   ) {help; exit 777;}
      elsif ( /^-1$/ || /^--debug1$/ ) {$Db = 1;}
      elsif ( /^-2$/ || /^--debug2$/ ) {$Db = 2;}
      elsif ( /^-3$/ || /^--debug3$/ ) {$Db = 3;}
   }
   return 1;
} # end sub argv

sub aggregate {

   # ---------------------------------------------------------------------------------------------------------
   # Aggregate Toontown Screenshots From Toontown Program Director(y|ies) To Screeshots Directory:

   # File aggregation method will vary depending on platform:
   if ( $platform eq 'Linux'  ) {
      # Set directory variables for Linux:
      $program_dir_1   = '/home/aragorn/.var/app/com.toontownrewritten.Launcher/data/screenshots';
      $screenshots_dir = '/d/Arcade/Toontown-Rewritten/Screenshots';

      if ( $Db ) {
         say STDERR 'In ATT, in "if (Linux)", about to aggregate.';
         say STDERR "Platform                = $platform";
         say STDERR "Source      directory 1 = $program_dir_1";
         say STDERR "Source      directory 2 = $program_dir_2";
         say STDERR "Destination directory   = $screenshots_dir";
         if ( 1 == $Db ) {exit 111}
      }

      # Aggregate Toontown screenshots from the all-accounts program directory to Arcade:
      system("move-files.pl '$program_dir_1' '$screenshots_dir' '$image_regexp'");
   }
   elsif ( $platform eq 'Win64' ) {
      # Set directory variables for Windows:
      $program_dir_1   = '/c/Programs/Games/Toontown-Rewritten-A1/screenshots';
      $program_dir_2   = '/c/Programs/Games/Toontown-Rewritten-A2/screenshots';
      $screenshots_dir = '/d/Arcade/Toontown-Rewritten/Screenshots';

      if ( $Db ) {
         say STDERR 'In ATT, in "if (Win64)", about to aggregate.';
         say STDERR "Platform                = $platform";
         say STDERR "Source      directory 1 = $program_dir_1";
         say STDERR "Source      directory 2 = $program_dir_2";
         say STDERR "Destination directory   = $screenshots_dir";
         if ( 1 == $Db ) {exit 111}
      }

      # Aggregate Toontown screenshots from both per-account program directories to Arcade:
      system("move-files.pl '$program_dir_1' '$screenshots_dir' '$image_regexp'");
      system("move-files.pl '$program_dir_2' '$screenshots_dir' '$image_regexp'");
   }
   else {
      if ( $Db ) {
         say STDERR 'In ATT, in "if (invalid platform)", about to die.';
         say STDERR "Platform                = $platform";
         say STDERR "Source      directory 1 = $program_dir_1";
         say STDERR "Source      directory 2 = $program_dir_2";
         say STDERR "Destination directory   = $screenshots_dir";
         if ( 1 == $Db ) {exit 111}
      }
      die "Error in \"aggregate-toontown.pl\":\nInvalid platform \"$platform\".\n$!\n";
   }

   # ---------------------------------------------------------------------------------------------------------
   # Re-name Screenshots:

   # Enter screenshots directory:
   chdir $screenshots_dir;

   # Get ref to list of file-info hashes for all jpg and png files in screenshots directory:
   my $ImageFiles1 = GetFiles($screenshots_dir, 'F', $image_regexp);
   my $num1 = scalar @$ImageFiles1;

   if ( $Db )
   {
      say STDERR 'In ATT, about to rename files.';
      say STDERR "Screenshots dir = \"$screenshots_dir\".";
      # Sanity check!!! Are we actually where we think we are???
      my $cwd = cwd;
      say STDERR "CWD = \"$cwd\".";
      say STDERR "Number of files before renaming = $num1";
      say STDERR "Names  of files before renaming:";
      say STDERR $_->{Name} for @$ImageFiles1;
      if ( 2 == $Db ) {exit 222}
   }

   # Rename Toontown screenshot files as necessary:
   say STDOUT '';
   say STDOUT 'Now canonicalizing names of Toontown screenshots....';
   system('rename-toontown-images.pl -v');

   # Get ref to FRESH list of file-info hashes for all jpg and png files in screenshots directory
   # (NOTE: all the names will have changed, so we can't re-use old list):
   my $ImageFiles2 = GetFiles($screenshots_dir, 'F', $image_regexp);
   my $num2 = scalar(@$ImageFiles2);

   if ( $Db )
   {
      say STDERR 'In ATT, after renaming files.';
      say STDERR "Screenshots dir = \"$screenshots_dir\".";
      # Sanity check!!! Are we actually where we think we are???
      my $cwd = cwd;
      say STDERR "CWD = \"$cwd\".";
      say STDERR "Number of files after renaming = $num2";
      say STDERR "Names  of files after renaming:";
      say STDERR $_->{Name} for @$ImageFiles2;
      if ( 3 == $Db ) {exit 333}
   }

   # ---------------------------------------------------------------------------------------------------------
   # File Screenshots By Date:

   say STDOUT '';
   say STDOUT 'Now filing Toontown images by date....';
   foreach my $file (@$ImageFiles2)
   {
      my $path  = $file->{Path};
      my $name  = $file->{Name};
      my $pref  = get_prefix($name);
      my @Parts = split /[-_]/, $pref;
      my $year  = $Parts[2];
      my $month = $Parts[3];
      if ( ! -e $year ) {mkdir $year }
      my $dir   = $year . '/' . $month;
      if ( ! -e $dir  ) {mkdir $dir  }
      move_file($path, $dir);
   }
   say STDOUT '';
   say STDOUT 'Finished filing Toontown images by date.';

   # Return success code 1 to caller:
   return 1;
} # end sub aggregate

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "aggregate-towntown.pl". This program moves all screenshots
   from the Toontown-Rewritten program director(y|ies) to the directory
   "/d/Arcade/Toontown-Rewritten/Screenshots". It then renames the files according
   to a chronological-order naming format, then moves the files into appropriate
   year/month subdirectories of the screenshots directory.

   -------------------------------------------------------------------------------
   Command Lines:

   aggregate-towntown.pl [-h | --help]  (to print this help and exit)
   aggregate-towntown.pl [-1|-2|-3]     (to simulate screenshot aggregation)
   aggregate-towntown.pl                (to aggregate screenshots)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:         Meaning:
   -h or --help    Print this help and exit.
   -1 or --debug1  Print diagnostics and exit after first  breakpoint.
   -2 or --debug2  Print diagnostics and exit after second breakpoint.
   -3 or --debug3  Print diagnostics and exit after third  breakpoint.

   Single-letter options may NOT be piled-up after a single hyphen in this
   program, because they all contradict each other; at most one may be used.
   If two contradictory options are used, the right-most dominates.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   You can type as many arguments as you like on the command line, but this
   program will ignore them all. If you need to alter what this program does,
   edit this script.

   "Going UP, sir!"

   Happy Toontown screenshot aggregating!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
