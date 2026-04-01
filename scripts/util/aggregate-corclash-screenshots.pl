#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# aggregate-corclash-screenshots.pl
# Aggregates Corporate-Clash screenshots from program directory to screenshots directory.
#
# Written by Robbie Hatley.
#
# Edit history:
# Thu Mar 26, 2026: Wrote it, based heavily on "aggregate-toontown-screenshots.pl".
# Fri Mar 27, 2026: Now renames files. Handled time zone ambiguity. To-do: file files by date.
# Fri Mar 27, 2026: Now also files files by date. Program is essentially complete. Yeah! 🥳
# Sat Mar 28, 2026: Renamed from "aggregate-corclash-snapshots.pl" to "aggregate-corclash-screenshots.pl".
# Sat Mar 28, 2026: Changed "ATS" to "ACS". Fixed double program entry notice.
# Sun Mar 29, 2026: Made more concise: No-longer re-specifies directories with every move.
# Sun Mar 29, 2026: Added and edited some comments.
# Sun Mar 29, 2026: Fixed multiple bugs which were resulting in deletion of files. Removed "unlink".
#                   Added MUCH more error checking and warning messages.
# Mon Mar 30, 2026: 1. Added RE check of files before moving from program_dir.
#                   2. Now no-longer moves files from program_dir if at debug level 1.
#                   3. Now announces beginning and end of moving files from program_dir to screens_dir.
#                   4. Now doesn't print dir paths for each operation, just "program_dir" or "screens_dir".
#                   5. Fixed bugs in help which were printing path instead of literal "screens_dir".
##############################################################################################################

# ======= PRELIMINARIES: =====================================================================================

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
use File::Copy 'move';
use POSIX 'tzset';

# ======= VARIABLES: =========================================================================================

# ------- System Variables: ----------------------------------------------------------------------------------

$" = ', ' ; # Quoted-array element separator = ", ".

# ------- Global Variables: ----------------------------------------------------------------------------------

our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.

# ------- Local variables: -----------------------------------------------------------------------------------

# Settings:
my $Db           = 'not_set'; # Shall we debug? And if so, at what level?
my $image_regexp = 'not_set'; # What regular expression shall we use for finding images?
my $program_dir  = 'not_set'; # What is the first  program directory?
my $screens_dir  = 'not_set'; # What is the screenshots directory?

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub set_settings; # Set settings.
sub aggregate;    # Aggregate Corporate-Clash screenshots.
sub help;         # Print help.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Start execution timer:
   my $t0 = time;
   my @s0 = localtime($t0);

   # Announce program entry:
   printf STDERR "Now entering program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n\n",
                 $s0[2], $s0[1], $s0[0], 1+$s0[4], $s0[3], 1900+$s0[5];

   # Set settings:
   set_settings;

   # Print settings:
   say    "Program dir     = $program_dir";
   say    "Screenshots dir = $screens_dir";

   # Aggregate Corporate-Clash screenshots:
   aggregate;

   # Stop execution timer:
   my $t1 = time;
   my @s1 = localtime($t1);

   # Announce program exit and execution time:
   my $te = $t1 - $t0; my $ms = 1000 * $te;
   printf STDERR "\nNow exiting program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n",
                 $s1[2], $s1[1], $s1[0], 1+$s1[4], $s1[3], 1900+$s1[5];
   printf STDERR "Execution time was %.3fms.\n", $ms;

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Set settings:
sub set_settings {
   # Default $Db to 0:
   $Db = 0;

   # Set $image_regexp:
   $image_regexp = qr/\.jpg$|\.png$/io;

   # Set directories based on ini file, if it exists:
   my $script_file = __FILE__ ;
   my $script_dire = ($script_file =~ s#(?:/[^/]+)$##r);
   chdir "$script_dire" or die "Error: Couldn't cd to \"$script_dire\".\n$!\n";
   my $inifile = 'aggregate-corclash-screenshots.ini';
   if ( -e "$inifile" && -f "$inifile" ) {
      open(FH, "<", "$inifile") or die "Error: couldn't open ini file.\n$!\n";
      while (<FH>) {
         m/progdir\s*=\s*(.+)/ and $program_dir = $1;
         m/scrndir\s*=\s*(.+)/ and $screens_dir = $1;
      }
      close(FH) or die "Error: couldn't open ini file.\n$!\n";
   }

   # Process @ARGV:
   for ( @ARGV ) {
         if ( /^-h$/ || /^--help$/   )    {help; exit 777;}
      elsif ( /^-1$/ || /^--debug1$/ )    {$Db = 1;}
      elsif ( /^-2$/ || /^--debug2$/ )    {$Db = 2;}
      elsif ( /^-3$/ || /^--debug3$/ )    {$Db = 3;}
      elsif ( /^-4$/ || /^--debug4$/ )    {$Db = 4;}
      elsif ( /--program_dir\s*=\s*(.+)/ ) {$program_dir = $1} # Over-rides ini file.
      elsif ( /--$screens_dir\s*=\s*(.+)/ ) {$screens_dir = $1} # Over-rides ini file.
   }

   # Abort program if $program_dir is not set:
   if ( 'not_set' eq $program_dir || ! -e $program_dir || ! -d $program_dir ) {
      die "Error: program directory not set; use \"--help\" to get help.\n";
   }

   # Abort program if $screens_dir is not set:
   if ( 'not_set' eq $screens_dir || ! -e $screens_dir || ! -d $screens_dir ) {
      die "Error: screens directory not set; use \"--help\" to get help.\n";
   }

   # BREAKPOINT 1: If debugging, run sanity checks; if debug level is 1, exit here:
   if ( $Db ) {
      say STDERR '';
      say STDERR 'In ACS, at breakpoint 1, in sub "set_settings". Values of settings:';
      say STDERR "Db              = $Db";
      say STDERR "Image RegExp    = $image_regexp";
      say STDERR "Program dir     = \"$program_dir\".";
      say STDERR "Screenshots dir = \"$screens_dir\".";
      if ( 1 == $Db ) {exit 111}
   }

   # Return success code '1' to caller:
   return 1;
} # end sub set_settings

# Aggregate Corporate-Clash screenshots:
sub aggregate {
   # =========================================================================================================
   # PHASE 1: Move Corporate-Clash screenshots from program directory to screenshots directory:

   # First make sure that these two directories exist and are directories:
   if ( ! -e $program_dir ) {die "Error in ACS: program directory does not exist!\n$!\n";}
   if ( ! -d $program_dir ) {die "Error in ACS: program directory is not a directory!\n$!\n";}
   if ( ! -e $screens_dir ) {die "Error in ACS: screenshots directory does not exist!\n$!\n";}
   if ( ! -d $screens_dir ) {die "Error in ACS: screenshots directory is not a directory!\n$!\n";}

   # Enter program directory:
   chdir $program_dir
   or die "Error in ACS, in sub aggregate: couldn't cd to \"$program_dir\".\n$!\n";

   # Get list of "*.png" file names:
   my @names1 = <*.png>;
   my $num1 = scalar @names1;

   say STDOUT '';
   say STDOUT 'Now moving screenshots from program_dir to screens_dir....';

   # Move all screenshots to the screenshots directory, unless a file of that name already exists there
   # (in which case skip that file), or unless at debug level 1 (in which case just emulate moving):
   for my $name1 (@names1) {
      # As of 2026, typical CCL screenshots are formateed like this:
      # corporateclash-screenshot-1774787469.png
      # Skip this file if it doesn't match regexp:
      if ( $name1 !~ m/^corporateclash-screenshot-\d{10}\.png$/ ) {
         say STDERR "Warning: File \"$name1\" in program_dir\n"
                   ."does not have a valid original-CCL-screenshot name;\n"
                   ."skipping this file and moving on to the next.";
         next;
      }
      # If a duplicate of $name1 exists in screens_dir, print a warning and skip this file:
      if ( -e "$screens_dir/$name1" ) {
         say STDERR "Warning: file \"$name1\" in program_dir has a duplicate\n"
                   ."in screens_dir; skipping this file and moving on to the next.";
         next;
      }
      # If at debug level 1, emulate move; otherwise, move file:
      if ( 1 == $Db ) {
         say STDERR "Would have moved file \"$name1\" from program_dir to screens_dir.";
         next;
      }
      else {
         move($name1, $screens_dir)
         and say  "Moved \"$name1\" from program_dir to screens_dir."
         or  warn "Error: Failed to move \"$name1\" from program_dir to screens_dir.\n$!\n";
      }
   }

   say STDOUT 'Finished moving screenshots from program_dir to screens_dir.';

   # Enter screenshots directory:
   chdir $screens_dir
   or die "Error in ACS, in sub aggregate: couldn't cd to \"$screens_dir\".\n$!\n";

   # Get fresh list of "*.png" file names:
   my @names2 = <*.png>;
   my $num2 = scalar @names2;

   # Set file permissions of screenshots so that user and group can read and write but others can read only:
   for my $name2 (@names2) {
      chmod 0664, $name2;
   }

   # BREAKPOINT 2: If debugging, run sanity checks; if debug level is 2, exit here:
   if ( $Db )
   {
      say STDERR '';
      say STDERR 'In ACS, at breakpoint 2, in sub "aggregate", after moving and before renaming.';
      say STDERR 'Let’s do a sanity check! Are we actually where we think we are?';
      my $cwd = cwd;
      say STDERR "Screenshots dir = \"$screens_dir\".";
      say STDERR "Current wrk dir = \"$cwd\".";
      $cwd eq $screens_dir
      and say STDERR 'Hooray, the two match!'
      or  say STDERR 'Oh-oh, the two don’t match!';
      say STDERR "Number of files before moving = $num1";
      say STDERR "Number of files after  moving = $num2";
      $num1 == $num2
      and say STDERR 'Hooray, number of files stayed the same after moving to $screens_dir!'
      or  say STDERR 'Oh-oh, number of files changed after moving to $screens_dir!';
      if ( 2 == $Db ) {exit 222}
   }

   # =========================================================================================================
   # PHASE 2: Rename Screenshots:

   say STDOUT '';
   say STDOUT 'Now canonicalizing names of screenshots....';
   { # Begin localization of time zone.
      local $ENV{TZ} = 'America/Los_Angeles';
      tzset();
      for my $name2 (@names2) {
         # As of 2026, typical CCL screenshots are formateed like this:
         # corporateclash-screenshot-1774787469.png
         # Capture fields; skip file if file doesn't match regexp:
         if ( !($name2 =~ m/^corporateclash-screenshot-(\d{10})\.png$/) ) {
            say STDERR "Warning: File \"$name2\" in screens_dir\n"
                      ."does not have a valid original-CCL-screenshot name;\n"
                      ."skipping this file and moving on to the next.";
            next;
         }
         # Make the fields we need for our new screenshot format:
         my ($lt_sec, $lt_min, $lt_hou, $lt_dom, $lt_mon, $lt_year, $lt_dow, $lt_doy, $lt_dst) = localtime $1;
         my $year = 1900+$lt_year;
         my $mnth = $lt_mon + 1;
         my $domn = $lt_dom;
         my $dowk = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")[$lt_dow];
         my $hour = $lt_hou;
         my $minu = $lt_min;
         my $seco = $lt_sec;
         if ($Db) {say "$year-$mnth-$domn-$dowk $hour-$minu-$seco";}
         # If any of these are now not defined or have wrong values, print warning and skip this file:
         if (     !defined($year) || $year < 2000 || $year > 2999
               || !defined($mnth) || $mnth <    1 || $mnth >   12
               || !defined($domn) || $domn <    1 || $domn >   31
               || !defined($dowk) || !($dowk =~ m/\pL\pL\pL/)
               || !defined($hour) || $hour <    0 || $hour >   23
               || !defined($minu) || $minu <    0 || $minu >   59
               || !defined($seco) || $seco <    0 || $seco >   59 )  {
            say STDERR "Warning: file \"$name2\" in screens_dir\n"
                      ."does not have the expected fields of\n"
                      ."a valid original-CCL-screenshot name;\n"
                      ."skipping this file and moving on to the next.";
            next;
         }
         # Create new name:
         my $new_name = sprintf("ccl-screenshot_%4d-%02d-%02d-%s_%02d-%02d-%02d.png", $year, $mnth, $domn, $dowk, $hour, $minu, $seco);
         if (3 == $Db) {
            say "Would have renamed file to \"$new_name\".";
         }
         else {
            rename($name2, $new_name)
            and say  "Renamed \"$name2\" to \"$new_name\"."
            or  warn "Error: Failed to rename \"$name2\" to \"$new_name\".";
         } # end else (rename file)
      } # end for (each file)
   } # end localization of time zone
   tzset(); # Reset time zone back to normal.
   say STDOUT 'Finished canonicalizing names of screenshots.';

   # Get fresh list of "*.png" file names:
   my @names3 = <*.png>;
   my $num3 = scalar @names3;

   # BREAKPOINT 3: If debugging, run sanity checks; if debug level is 3, exit here:
   if ( $Db )
   {
      say STDERR '';
      say STDERR 'In ACS, at breakpoint 3, in sub "aggregate", after renaming files.';
      say STDERR 'Let’s do another sanity check! Are we still where we think we are?';
      my $cwd = cwd;
      say STDERR "Screenshots dir = \"$screens_dir\".";
      say STDERR "Current wrk dir = \"$cwd\".";
      $cwd eq $screens_dir
      and say STDERR 'Hooray, the two match!'
      or  say STDERR 'Oh-oh, the two don’t match!';
      say STDERR "Number of files before renaming = $num2";
      say STDERR "Number of files after  renaming = $num3";
      $num2 == $num3
      and say STDERR 'Hooray, number of files stayed the same after renaming!'
      or  say STDERR 'Oh-oh, number of files changed after renaming!';
      if ( 3 == $Db ) {exit 333}
   }

   # =========================================================================================================
   # PHASE 3: File Screenshots By Date:

   say STDOUT '';
   say STDOUT 'Now filing CCL screenshots by date....';
   foreach my $name3 (@names3) {
      # If this file doesn't match "renamed file" regexp, print warning and skip file:
      if ( $name3 !~ m/^ccl-screenshot_\d{4}-\d{2}-\d{2}-\pL{3}_\d{2}-\d{2}-\d{2}\.png$/ )  {
         say STDERR "Warning: file \"$name3\" in screens_dir\n"
                   ."does not have a valid renamed-CCL-screenshot name;\n"
                   ."skipping this file and moving on to the next.";
         next;
      }

      # Get prefix, label, date, time, and id; if anything is out-of-range, print warning and skip file:
      my $prefix = ($name3 =~ s/\.png$//r);
      my ($label, $date, $time) = split /_/, $prefix;
      if (     !defined($label)   || !($label   =~ m/^ccl-screenshot$/          )
            || !defined($date)    || !($date    =~ m/^\d{4}-\d{2}-\d{2}-\pL{3}$/)
            || !defined($time)    || !($time    =~ m/^\d{2}-\d{2}-\d{2}$/       ) ) {
         say STDERR "Warning: file \"$name3\" in $screens_dir\n"
                   ."does not have the expected 3 underscore-separated fields;\n"
                   ."skipping this file and moving on to the next.";
         next;
      }

      # Get year, month, day, and dayname; if anthing is out-of-range, print warning and skip file:
      my ($year, $month, $day, $dayname) = split /-/, $date;
      if (     !defined($year)    || !($year    =~ m/^2\d\d\d$/  )
            || !defined($month)   || !($month   =~ m/^\d\d$/     )
            || !defined($day)     || !($day     =~ m/^\d\d$/     )
            || !defined($dayname) || !($dayname =~ m/^\pL\pL\pL$/) ) {
         say STDERR "Warning: file \"$name3\" in screens_dir\n"
                   ."has a date which does not have the expected 4 hyphen-separated fields;\n"
                   ."skipping this file and moving on to the next.";
         next;
      }

      # If the needed directories do not yet exist, create them:
      my $year_dir = $year;
      my $mnth_dir = $year . '/' . $month;
      if ( ! -e $year_dir ) {mkdir $year_dir }
      if ( ! -e $mnth_dir ) {mkdir $year_dir }

      # If debug level is 4, emulate filing files; otherwise, file files by date:
      if (4 == $Db) {
         say STDERR "Would have moved file \"$name3\" to directory \"$mnth_dir\".";
      }
      else {
         if ( -e "$mnth_dir/$name3" ) {
            say STDERR "Warning: file \"$name3\" has a duplicate in directory \"$mnth_dir\";\n"
                      ."skipping this file and moving on to the next.";
            next;
         }
         move($name3, $mnth_dir)
         and say  "Moved \"$name3\" from screens_dir to \"$mnth_dir\"."
         or  warn "Error: Failed to move \"$name3\" from screens_dir to \"$mnth_dir\".\n$!\n";
      }
   }
   say STDOUT 'Finished filing CCL screenshots by date.';

   # BREAKPOINT 4: If debugging, run sanity checks; if debug level is 4, don't exit here, because we're almost done:
   if ( $Db )
   {
      say STDERR '';
      say STDERR 'In ACS, in sub "aggregate", after filing files by date.';
      say STDERR 'Let’s do another sanity check! Are we still where we think we are?';
      my $cwd = cwd;
      say STDERR "Screenshots dir = \"$screens_dir\".";
      say STDERR "Current wrk dir = \"$cwd\".";
      $cwd eq $screens_dir
      and say STDERR 'Hooray, the two match!'
      or  say STDERR 'Oh-oh, the two don’t match!';
      say STDERR 'The number of png files in the current directory should now be 0. Let’s check that....';
      my @pngs = <*.png>;
      my $numpng = scalar @pngs;
      0 == $numpng
      and say 'Hooray, no png files left!'
      or  say "Oh-oh, $numpng files are left; something went wrong!";
      if ( 4 == $Db ) {;} # Don't exit, because we're almost done. Let normal program exit message print.
   }

   # Return success code 1 to caller:
   return 1;
} # end sub aggregate

sub help {
   print ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "$pname". This program moves all
   screenshots from your Corporate-Clash program's screenshots directory to
   dated subdirectories of a screenshots directory of your choice. For this
   program to work, you must first specify these two directories. You can do this
   in one of two ways:

   Method #1: Put a file named "aggregate-corclash-screenshots.ini" in the same
   directory as this script, and put your directories in there, in this syntax:

   [Locations]
   program_dir = /opt/corporate-clash/screenshots
   screens_dir = /home/jack/corporate-clash-screenshots

   (Substitute-in the actual directories you're using.)

   Method #2: Write the directories as options on your command line, using this
   syntax:

   aggregate-corclash-screenshots.pl \
   --program_dir=/opt/corporate-clash/screenshots \
   --screens_dir=/home/jack/corporate-clash-screenshots

   (Substitute-in the actual directories you're using.)

   -------------------------------------------------------------------------------
   Command Lines:

   $pname [-h | --help]  (to print this help and exit)
   $pname [-1|-2|-3|-4]  (to debug)
   $pname [options]      (to aggregate screenshots)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:             Meaning:
   -h or --help        Print this help and exit.
   --program_dir=/dir1  Set program's screenshots directory
   --screens_dir=/dir2  Set your own  screenshots directory
   -1 or --debug1      Print diagnostics and exit at first  breakpoint.
   -2 or --debug2      Print diagnostics and exit at second breakpoint.
   -3 or --debug3      Print diagnostics and exit at third  breakpoint.
   -4 or --debug4      Print diagnostics and exit at fourth breakpoint.

   Single-letter options may NOT be piled-up after a single hyphen in this
   program, because they all contradict each other; at most one may be used.
   If two contradictory options are used, the right-most dominates.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   This program cheerfully ignores all non-option arguments.

   "Going UP, sir!"

   Happy Corporate-Clash screenshot aggregating!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
