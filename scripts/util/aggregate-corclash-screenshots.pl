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
# Sun Apr 05, 2026: Fixed bug in which files were being destructively written on top of each other due to
#                   a malformed month directory being misconstrued as being a regular file, and due to
#                   a move() call being ambiguously formatted 'move("fil", "dir")' instead of the
#                   much-less-ambiguous 'move("fil", "dir/fil")'. I've stopped using "move" altogether for
#                   the next few months, until I can be very sure that this script is behaving correctly.
#                   Instead, I'm copying files from program_dir to screens_dir, and copying files from
#                   screens_dir to date dirs. This leaves 3 copies of everything on-system, including on two
#                   separate physical devices with two different backup schemes.
##############################################################################################################

# ======= PRELIMINARIES: =====================================================================================

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
use File::Copy qw( copy move );
use POSIX 'tzset';

# ======= VARIABLES: =========================================================================================

# ------- System Variables: ----------------------------------------------------------------------------------

$" = ', ' ; # Quoted-array element separator = ", ".

# ------- Global Variables: ----------------------------------------------------------------------------------

our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.

# ------- Local variables: -----------------------------------------------------------------------------------

# Settings:
my $Db          =     0     ; # Shall we debug? And if so, at what level? (0, 1, 2, 3, or 4?)
my $program_dir = 'not_set' ; # What is the first  program directory?
my $screens_dir = 'not_set' ; # What is the screenshots directory?

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub set_settings;  # Set settings.
sub make_new_name; # Make a new name for a CCL screenshot file.
sub aggregate;     # Aggregate Corporate-Clash screenshots.
sub help;          # Print help.

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

   { # Aggregate Corporate-Clash screenshots:
      local $ENV{TZ} = 'America/Los_Angeles';
      tzset();
      aggregate;
   } # Local $ENV{TZ} goes out-of-scope here.
   tzset(); # Reset time zone back to previous value.

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
   # Set directories based on ini file, if it exists:
   my $script_file = __FILE__ ;
   my $script_dire = ($script_file =~ s#(?:/[^/]+)$##r);
   chdir $script_dire or die "Error: Couldn't cd to \"$script_dire\".\n$!\n";
   my $inifile = 'aggregate-corclash-screenshots.ini';
   if ( -e $inifile && -f $inifile ) {
      my $fh = undef;
      if (open($fh, "<", $inifile)) {
         while (<$fh>) {
            m/^\s*program_dir\s*=\s*(.+)$/ and $program_dir = $1;
            m/^\s*screens_dir\s*=\s*(.+)$/ and $screens_dir = $1;
         }
         close($fh) or warn "Warning: couldn't close ini file.\n$!\n";
      }
      else {
         warn "Warning: couldn't open ini file.\n$!\n";
      }
   }

   # Process @ARGV:
   for ( @ARGV ) {
         if ( /^-h$/ || /^--help$/   )    {help; exit 777;}
      elsif ( /^-1$/ || /^--debug1$/ )    {$Db = 1;}
      elsif ( /^-2$/ || /^--debug2$/ )    {$Db = 2;}
      elsif ( /^-3$/ || /^--debug3$/ )    {$Db = 3;}
      elsif ( /^-4$/ || /^--debug4$/ )    {$Db = 4;}
      elsif ( /^--program_dir\s*=\s*(.+)$/ ) {$program_dir = $1} # Over-rides ini file.
      elsif ( /^--screens_dir\s*=\s*(.+)$/ ) {$screens_dir = $1} # Over-rides ini file.
   }

   # Abort program if $program_dir or $screens_dir is not set:
   'not_set' eq $program_dir and die "Error: program directory not set; use \"--help\" to get help.\n";
   'not_set' eq $screens_dir and die "Error: screens directory not set; use \"--help\" to get help.\n";

   # Remove any leading or trailing space or single or double quotes from $program_dir:
   $program_dir =~ s/^\s+//;
   $program_dir =~ s/\s+$//;
   $program_dir =~ s/^'(.*)'$/$1/;
   $program_dir =~ s/^"(.*)"$/$1/;

   # Remove any leading or trailing space or single or double quotes from $screens_dir:
   $screens_dir =~ s/^\s+//;
   $screens_dir =~ s/\s+$//;
   $screens_dir =~ s/^'(.*)'$/$1/;
   $screens_dir =~ s/^"(.*)"$/$1/;

   # Print $program_dir and $screens_dir to STDOUT:
   say "program_dir = $program_dir";
   say "screens_dir = $screens_dir";

   # Make sure program_dir is non-empty, exists, and is a directory:
   $program_dir =~ m/^$/ and die "Error: program directory name must not be an empty string; use \"--help\" to get help.\n";
   ! -e $program_dir     and die "Error: program directory does not exist; use \"--help\" to get help.\n";
   ! -d $program_dir     and die "Error: program directory is not a directory; use \"--help\" to get help.\n";

   # Make sure screens_dir exists and is a directory:
   $screens_dir =~ m/^$/ and die "Error: screens directory name must not be an empty string; use \"--help\" to get help.\n";
   ! -e $screens_dir     and die "Error: screens directory does not exist; use \"--help\" to get help.\n";
   ! -d $screens_dir     and die "Error: screens directory is not a directory; use \"--help\" to get help.\n";

   # Return success code '1' to caller:
   return 1;
} # end sub set_settings

# Make a new name for a CCL screenshot file:
sub make_new_name ( $old_name ) {
   # As of 2026, typical CCL screenshots are formatted like this:
   # corporateclash-screenshot-1774787469.png
   # Capture fields; return '***ERROR***' if file doesn't match regexp:
   return '***ERROR***' if $old_name !~ m/^corporateclash-screenshot-(\d{10})\.png$/;
   # Make the fields we need for our new screenshot format:
   my ($lt_sec, $lt_min, $lt_hou, $lt_dom, $lt_mon, $lt_year, $lt_dow, $lt_doy, $lt_dst) = localtime $1;
   my $year = 1900+$lt_year;
   my $mnth = $lt_mon + 1;
   my $domn = $lt_dom;
   my $dowk = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")[$lt_dow];
   my $hour = $lt_hou;
   my $minu = $lt_min;
   my $seco = $lt_sec;
   # If any of these are now not defined or have wrong values, return '***ERROR***':
   return '***ERROR***' if
         !defined($year) || $year < 2000 || $year > 2999
      || !defined($mnth) || $mnth <    1 || $mnth >   12
      || !defined($domn) || $domn <    1 || $domn >   31
      || !defined($dowk) || !($dowk =~ m/^\pL\pL\pL$/)
      || !defined($hour) || $hour <    0 || $hour >   23
      || !defined($minu) || $minu <    0 || $minu >   59
      || !defined($seco) || $seco <    0 || $seco >   59;
   # Create new name:
   sprintf("ccl-screenshot_%4d-%02d-%02d-%s_%02d-%02d-%02d.png", $year, $mnth, $domn, $dowk, $hour, $minu, $seco);
}

# Aggregate Corporate-Clash screenshots:
sub aggregate {
   # BREAKPOINT 1: If debugging, run sanity checks; if debug level is 1, exit here:
   if ( $Db ) {
      say STDERR '';
      say STDERR 'In ACS, at breakpoint 1, at top of sub "aggregate". Values of settings:';
      say STDERR "Db          = $Db";
      say STDERR "program_dir = \"$program_dir\".";
      say STDERR "screens_dir = \"$screens_dir\".";
      if ( 1 == $Db ) {exit 111}
   }

   # =========================================================================================================
   # PHASE 1: Copy Corporate-Clash screenshots from program directory to screenshots directory:

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
   say STDOUT 'Now copying screenshots from program_dir to screens_dir....';
   # Copy all screenshots to the screenshots directory, unless a file of that name, or of an equivalent
   # new-style name, already exists there, or unless at debug level 1 (in which case just emulate copying):
   for my $name1 (@names1) {
      # As of 2026, typical CCL screenshots are formateed like this:
      # corporateclash-screenshot-1774787469.png
      # Print a warning and skip this file if it doesn't match regexp:
      if ( $name1 !~ m/^corporateclash-screenshot-\d{10}\.png$/ ) {
         say STDERR "Warning: File \"$name1\" in program_dir\n"
                   ."does not have a valid original-CCL-screenshot name;\n"
                   ."skipping this file and moving on to the next.";
         next;
      }
      # Silently skip current file if a file named "$name1" exists in screens_dir:
      next if -e "$screens_dir/$name1";
      # Get the new-style name for this file:
      my $new_name = make_new_name($name1);
      # Skip current file and print warning if new name is '***ERROR***':
      if ('***ERROR***' eq $new_name) {
         say STDERR "Warning: couldn’t make valid new name for file \"$name1\"\n"
                   ."in program_dir; skipping this file and moving on to next.";
         next;
      }
      # Silently skip current file if a file named "$new_name" exists in screens_dir:
      next if -e "$screens_dir/$new_name";
      # If at debug level 1, emulate copy:
      if ( 1 == $Db ) {
         say STDERR "Would have copied file \"$name1\" from program_dir to screens_dir.";
         next;
      }
      # Otherwise, copy file:
      else {
         copy($name1, "$screens_dir/$name1")
         and say  "Copied \"$name1\" from program_dir to screens_dir."
         or  warn "Error: Failed to copy \"$name1\" from program_dir to screens_dir.\n$!\n";
      }
   }
   say STDOUT 'Finished copying screenshots from program_dir to screens_dir.';

   # Enter screenshots directory:
   chdir $screens_dir
   or die "Error in ACS, in sub aggregate: couldn't cd to \"$screens_dir\".\n$!\n";

   # Get fresh list of "*.png" file names:
   my @names2 = <*.png>;
   my $num2 = scalar @names2;

   # Set file permissions of screenshots so that user and group can read and write but others can read only:
   for my $name2 (@names2) {
      chmod 0664, $name2
      or warn "Warning: Couldn't update permissions\non file \"$name2\" in screens_dir.\n$!\n";
   }

   # BREAKPOINT 2: If debugging, run sanity checks; if debug level is 2, exit here:
   if ( $Db )
   {
      say STDERR "\nIn acs, at breakpoint 2, in sub \"aggregate\", after copying files\n"
                ."from program_dir to screens_dir and before renaming files.\n"
                ."Let’s do a sanity check! Are we actually where we think we are?";
      my $cwd = cwd;
      say STDERR "Screenshots dir = \"$screens_dir\".";
      say STDERR "Current wrk dir = \"$cwd\".";
      $cwd eq $screens_dir
      and say STDERR 'Hooray, the two match!'
      or  say STDERR 'Oh-oh, the two don’t match!';
      say STDERR "Number of files in program_dir = $num1";
      say STDERR "Number of files in screens_dir = $num2";
      if ( 2 == $Db ) {exit 222}
   }

   # =========================================================================================================
   # PHASE 2: Rename Screenshots:

   say STDOUT '';
   say STDOUT 'Now canonicalizing names of screenshots....';
   for my $name2 (@names2) {
      # Silently skip current file if it doesn't have a valid original-style CCL screenshot name:
      next if $name2 !~ m/^corporateclash-screenshot-\d{10}\.png$/;
      # Get new file name:
      my $new_name = make_new_name($name2);
      # Skip to next file if current file couldn't be renamed:
      next if '***ERROR***' eq $new_name;
      # Skip to next file if a file with this new name already exists in screens_dir:
      next if -e $new_name;
      # If debugging, simulate rename:
      if (3 == $Db) {
         say "Would have renamed \"$name2\" to \"$new_name\".";
      }
      # Otherwise, rename file:
      else {
         rename($name2, $new_name)
         and say  "Renamed \"$name2\" to \"$new_name\"."
         or  warn "Error: Failed to rename \"$name2\" to \"$new_name\".";
      } # end else (rename file)
   } # end for (each file)
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
      say STDERR "Number of files in screens_dir before renaming = $num2";
      say STDERR "Number of files in screens_dir after  renaming = $num3";
      if ( 3 == $Db ) {exit 333}
   }

   # =========================================================================================================
   # PHASE 3: File Screenshots By Date:

   say STDOUT '';
   say STDOUT 'Now filing CCL screenshots by date....';
   foreach my $name3 (@names3) {
      # Silently skip this file if it doesn't match "renamed file" regexp:
      next if $name3 !~ m/^ccl-screenshot_\d{4}-\d{2}-\d{2}-\pL{3}_\d{2}-\d{2}-\d{2}\.png$/;

      # Get prefix, label, date, time, and id; if anything is out-of-range, print warning and skip file:
      my $prefix = $name3 =~ s/\.png$//r;
      my ($label, $date, $time) = split /_/, $prefix;
      if (     !defined($label)   || !($label   =~ m/^ccl-screenshot$/          )
            || !defined($date)    || !($date    =~ m/^\d{4}-\d{2}-\d{2}-\pL{3}$/)
            || !defined($time)    || !($time    =~ m/^\d{2}-\d{2}-\d{2}$/       ) ) {
         say STDERR "Warning: file \"$name3\" in screens_dir\n"
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
      if ( ! -e $year_dir ) {mkdir $year_dir or die "Error: Couldn't make directory \"$year_dir\".\n$!\n"}
      if ( ! -e $mnth_dir ) {mkdir $mnth_dir or die "Error: Couldn't make directory \"$mnth_dir\".\n$!\n"}

      # If debug level is 4, emulate filing files; otherwise, file files by date:
      if (4 == $Db) {
         say STDERR "Would have copied file \"$name3\" from screens_dir to \"$mnth_dir\".";
      }

      # Otherwise, attempt to copy the current file, after assuring needed directories actually do exist,
      # and after assuring that there is no file by this name in the destination directory:
      else {
         if ( ! -e $year_dir ) {die "Error: directory \"$year_dir\" in screens_dir does not exist.    \n$!\n"}
         if ( ! -d $year_dir ) {die "Error: directory \"$year_dir\" in screens_dir is not a directory.\n$!\n"}
         if ( ! -e $mnth_dir ) {die "Error: directory \"$mnth_dir\" in screens_dir does not exist.    \n$!\n"}
         if ( ! -d $mnth_dir ) {die "Error: directory \"$mnth_dir\" in screens_dir is not a directory.\n$!\n"}
         # Silently skip this file if a duplicate exists in the destination:
         next if -e "$mnth_dir/$name3";
         copy($name3, "$mnth_dir/$name3")
         and say  "Copied \"$name3\" from screens_dir to \"$mnth_dir\"."
         or  warn "Error: Failed to copy \"$name3\" from screens_dir to \"$mnth_dir\".\n$!\n";
      } # end else attempt to actually copy file.
   } # end copy each renamed file from screens_dir to mnth_dir
   say STDOUT 'Finished filing CCL screenshots by date.';

   # BREAKPOINT 4: If debugging, run sanity checks; if debug level is 4, don't exit here, because we're almost done:
   if ( $Db )
   {
      say STDERR '';
      say STDERR 'In ACS, at breakpoint 4, in sub "aggregate", after filing files by date.';
      say STDERR 'Let’s do another sanity check! Are we still where we think we are?';
      my $cwd = cwd;
      say STDERR "Screenshots dir = \"$screens_dir\".";
      say STDERR "Current wrk dir = \"$cwd\".";
      $cwd eq $screens_dir
      and say STDERR 'Hooray, the two match!'
      or  say STDERR 'Oh-oh, the two don’t match!';
      my @pngs = <*.png>;
      my $numpng = scalar @pngs;
      say "Root of screens_dir now contains $numpng png files.";
      if ( 4 == $Db ) {;} # Don't exit, because we're almost done. Let normal program exit message print.
   }

   # Return success code 1 to caller:
   return 1;
} # end sub aggregate

sub help {
   print ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "$pname". This program copies all
   screenshots from your Corporate-Clash program's screenshots directory to
   dated subdirectories of a screenshots directory of your choice. For this
   program to work, you must first specify these two directories. You can do this
   in one of two ways:

   Method #1: Put a file named "aggregate-corclash-screenshots.ini" in the same
   directory as this script, and put your directories in there, in this syntax:

   [Locations]
   # comment 1:
   program_dir = /opt/corporate-clash/screenshots
   # comment 2:
   screens_dir = /home/jack/corporate-clash-screenshots

   Substitute-in the actual directories you're using. But don't put any comments
   on the ends of the lines giving the paths or they will be construed as being
   part of those paths.

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
   --program_dir=/dir1 Set program's screenshots directory
   --screens_dir=/dir2 Set your own  screenshots directory
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
