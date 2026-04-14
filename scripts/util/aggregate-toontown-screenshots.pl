#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# aggregate-toontown-screenshots.pl
# Aggregates TTR screenshots from my two TTR program screenshots folders to a folder in my Arcade.
#
# Written by Robbie Hatley.
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
# Sat Nov 20, 2021: Refreshed shebang, colophon, title card, and boilerplate. Now using "common::sense".
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
# Thu Mar 26, 2026: Split into two branches:
#                   1. aggregate-corclash-screenshots.pl
#                   2. aggregate-toontown-screenshots.pl
# Fri Mar 27, 2026: Now renames files. Handled time zone ambiguity. To-do: file files by date.
# Fri Mar 27, 2026: Now also files files by date. Program is essentially complete. Yeah! 🥳
# Sat Mar 28, 2026: Fixed double program entry notice.
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
# Fri Apr 10, 2026: Now MOVING photos from screens_dir to date_dir, but still leaving the originals in
#                   program_dir for now.
# Sat Apr 11, 2026: Split "aggregate" into "PHASE_1", "PHASE_2", and "PHASE_3". Moved current-directory checks
#                   from breakpoints into main code. Simplified breakpoints. Reduced differences between the
#                   two versions of this file. Now prints "program_dir" and "screens_dir" instead of
#                   "$program_dir" and "$screens_dir". Now prints settings in main code (not Breakpoint 1).
# Sun Apr 12, 2026: Now uses centralized pre-compiled REs for valid original and renamed screenshot names.
##############################################################################################################

# ======= PRELIMINARIES: =====================================================================================

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
use File::Copy qw( copy move );
use POSIX 'tzset';

# ======= VARIABLES: =========================================================================================

# ------- Global Variables: ----------------------------------------------------------------------------------

our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.

# ------- Local variables: -----------------------------------------------------------------------------------

# Settings:
my $Db          =     0     ; # Shall we debug? And if so, at what level? (0, 1, 2, 3, or 4?)
my $program_dir = 'not_set' ; # What is the first  program directory?
my $screens_dir = 'not_set' ; # What is the screenshots directory?

# Regular expressions:
my $ttrw_original = qr/^ttr-screenshot-\pL{3}-\pL{3}-\d{2}-\d{2}-\d{2}-\d{2}-\d{4}-\d{1,18}\.png$/;
my $ttrw_renamed  = qr/^ttr-screenshot_\d{4}-\d{2}-\d{2}-\pL{3}_\d{2}-\d{2}-\d{2}_\d{1,18}\.png$/;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub set_settings;  # Set settings.
sub make_new_name; # Make a new name for a screenshot.
sub PHASE_1;       # Copy to screens_dir/original and move to screens_dir.
sub PHASE_2;       # Rename to time-and-date-based name.
sub PHASE_3;       # File in year/month subdirectories of screens_dir.
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

   { # Aggregate Toontown screenshots:
      local $ENV{TZ} = 'America/Los_Angeles';
      tzset();
      PHASE_1;
      PHASE_2;
      PHASE_3;
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
   my $inifile = 'aggregate-toontown-screenshots.ini';
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
      elsif ( /^--program_dir=(.+)$/ ) {$program_dir = $1} # Over-rides ini file.
      elsif ( /^--screens_dir=(.+)$/ ) {$screens_dir = $1} # Over-rides ini file.
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

   # Print settings:
   say "program_dir = $program_dir";
   say "screens_dir = $screens_dir";
   say "debug level = $Db";

   # Make sure program_dir has a non-empty-string name, exists, and is a directory:
   $program_dir =~ m/^$/ and die "Error: program directory name must not be an empty string; use \"--help\" to get help.\n";
   ! -e $program_dir     and die "Error: program directory does not exist; use \"--help\" to get help.\n";
   ! -d $program_dir     and die "Error: program directory is not a directory; use \"--help\" to get help.\n";

   # Make sure screens_dir has a non-empty-string name, exists, and is a directory:
   $screens_dir =~ m/^$/ and die "Error: screens directory name must not be an empty string; use \"--help\" to get help.\n";
   ! -e $screens_dir     and die "Error: screens directory does not exist; use \"--help\" to get help.\n";
   ! -d $screens_dir     and die "Error: screens directory is not a directory; use \"--help\" to get help.\n";

   # Return success code '1' to caller:
   return 1;
} # end sub set_settings

# Make a new name for a TTR screenshot file:
sub make_new_name ( $old_name ) {
# Make a hash of month numbers keyed by month names, for use in renaming files:
   my %months =
   (
      'Jan' => '01', 'Feb' => '02', 'Mar' => '03', 'Apr' => '04', 'May' => '05', 'Jun' => '06',
      'Jul' => '07', 'Aug' => '08', 'Sep' => '09', 'Oct' => '10', 'Nov' => '11', 'Dec' => '12'
   );

   # As of 2026, typical TTR screenshots are formatted like this:
   # ttr-screenshot_2026-03-30-Mon_02-39-34_157904.png
   # Print warning and return '***ERROR***' if file doesn't match regexp:
   if ( $old_name !~ m/$ttrw_original/ ) {
      warn "Warning: Old name does not match RE for valid original screenshot name.\n";
      return '***ERROR***';
   }

   # Make the fields we need for our new screenshot format:
   my $fields = $old_name =~ s/^ttr-screenshot-(.+?)\.png$/$1/r;
   if ($Db) {say "\$fields = $fields"}
   my ($dowk, $mnth, $domn, $hour, $minu, $seco, $year, $idst) = split /-/, $fields;

   # If any of these are now not defined or have wrong values, print warning and return '***ERROR***':
   if (     !defined($dowk) || $dowk !~ m/^\pL\pL\pL$/
         || !defined($mnth) || $mnth !~ m/^\pL\pL\pL$/
         || !defined($domn) || $domn !~ m/^\d\d$/
         || !defined($hour) || $hour !~ m/^\d\d$/
         || !defined($minu) || $minu !~ m/^\d\d$/
         || !defined($seco) || $seco !~ m/^\d\d$/
         || !defined($year) || $year !~ m/^2\d\d\d$/
         || !defined($idst) || $idst !~ m/^\d+$/      ) {
      warn "Warning: Malformed field for new name.\n";
      return '***ERROR***';
   }

   # Create new name:
   sprintf("ttr-screenshot_%4d-%02d-%02d-%s_%02d-%02d-%02d_%s.png", $year, $months{$mnth}, $domn, $dowk, $hour, $minu, $seco, $idst);
} # end sub make_new_name

# =========================================================================================================
# PHASE 1: Verify existence of "$program_dir" and "$screens_dir" directories, make "$screens_dir/original"
# directory if it doesn't exist, then for each screenshot in "$program_dir", first copy it to "original"
# then move it to "screens_dir":
sub PHASE_1 {
   # BREAKPOINT 1: If debugging, run sanity checks; if debug level is 1, exit here:
   if ( $Db ) {
      say STDERR '';
      say STDERR 'At Breakpoint 1 (before moving screenshots from program_dir to screens_dir).';
      if ( 1 == $Db ) {exit 111}
   }

   # First make sure that these two directories exist and are directories:
   if ( ! -e $program_dir ) {die "Fatal error in PHASE_1: program directory does not exist!\n$!\n";}
   if ( ! -d $program_dir ) {die "Fatal error in PHASE_1: program directory is not a directory!\n$!\n";}
   if ( ! -e $screens_dir ) {die "Fatal error in PHASE_1: screenshots directory does not exist!\n$!\n";}
   if ( ! -d $screens_dir ) {die "Fatal error in PHASE_1: screenshots directory is not a directory!\n$!\n";}

   # Make a directory to hold copies of original screenshots, if it doesn't already exist:
   if ( ! -e "$screens_dir/original" ) {
      mkdir "$screens_dir/original"
      or die "Fatal error in PHASE_1: \"original\" directory cannot be created.\nAborting execution.\n$!\n";
   }

   # Now double check to make sure that "$screens_dir/original" exists and is a directory:
   -e "$screens_dir/original"
   or die "Fatal error in PHASE_1: \"original\" directory does not exist.\nAborting execution.\n$!\n";
   -d "$screens_dir/original"
   or die "Fatal error in PHASE_1: \"original\" directory is not a directory.\nAborting execution.\n$!\n";

   # Enter program directory, if we're not already there:
   my $cwd = cwd;
   if ( $program_dir ne $cwd ) {
      chdir $program_dir
      or die "Fatal error in PHASE_1: Couldn't cd to program_dir.\n$!\n";
   }
   $cwd = cwd;
   if ( $program_dir ne $cwd ) {
      die "Fatal error in PHASE_1: Couldn't cd to program_dir.\n$!\n";
   }

   # Get list of "*.png" file names:
   my @names1 = <*.png>;
   my $num1 = scalar @names1;

   say STDOUT '';
   say STDOUT 'Now copying screenshots from program_dir to screens_dir/original then moving them to screens_dir....';
   # For each screenshot in "$program_dir", first copy it to "$screens_dir/original", then move it to
   # "$screens_dir", unless a file of that name, or of an equivalent new-style name, already exists there,
   # or unless at debug level 2 (in which case just emulate moving):
   for my $name1 (@names1) {
      # If at debug level 2, don't copy or move anything, just emulate:
      if ( 2 == $Db) {
         say "Would have copied file \"$name1\" from program_dir to screens_dir/original.";
         say "Would have moved  file \"$name1\" from program_dir to screens_dir.";
      }

      # Otherwise, copy current file to "$screens_dir/original" then move it to "$screens_dir":
      else {
         # Copy a copy to "$screens_dir/original" if it doesn't exist:
         if ( ! -e "$screens_dir/original/$name1" ) {
            copy("$program_dir/$name1", "$screens_dir/original/$name1")
            and say "Copied file \"$name1\" from program_dir to screens_dir/original."
            or warn "Warning: Unable to copy file \"$name1\" to \"original\" directory;\n"
                   ."skipping this file and moving on to next.\n$!\n"
            and next;
         }

         # As of 2026, typical TTR screenshots are formatted like this:
         # ttr-screenshot-Sun-Mar-29-00-06-34-2026-161310.png
         # Print a warning and skip this file if it doesn't match regexp:
         if ( $name1 !~ m/$ttrw_original/ ) {
            say STDERR "Warning: File \"$name1\" in program_dir\n"
                      ."does not have a valid original screenshot name;\n"
                      ."skipping this file and moving on to the next.";
            next;
         }

         # Print warning and skip current file if a file named "$name1" exists in screens_dir:
         if ( -e "$screens_dir/$name1" ) {
            warn "Warning: A file named \"$name1\" already exists in screens_dir; moving on to next file.\n";
            next;
         }

         # Get the new-style name for this file:
         my $new_name = make_new_name($name1);

         # Skip current file and print warning if new name is '***ERROR***':
         if ('***ERROR***' eq $new_name) {
            say STDERR "Warning: Couldn’t make valid new name for file \"$name1\"\n"
                      ."skipping this file and moving on to next.";
            next;
         }

         # Print warning and skip current file if a file named "$new_name" exists in screens_dir:
         if ( -e "$screens_dir/$new_name" ) {
            warn "Warning: A file named \"$new_name\" already exists in screens_dir;"
                ."skipping this file and moving on to next.\n";
            next;
         }

         # If we get to here, move file:
         move($name1, "$screens_dir/$name1")
         and say  "Moved  file \"$name1\" from program_dir to screens_dir." # Keep extra space after "Moved".
         or  warn "Error: Failed to move \"$name1\" from program_dir to screens_dir.\n$!\n";
      } # end else not emulating
   } # end for each original screenshot
   say STDOUT 'Finished moving screenshots from program_dir to screens_dir.';
} # end sub PHASE_1

# =========================================================================================================
# PHASE 2: Rename Screenshots:
sub PHASE_2 {
   # Enter screenshots directory, if we're not already there:
   my $cwd = cwd;
   if ( $screens_dir ne $cwd ) {
      chdir $screens_dir
      or die "Fatal error in PHASE_2: Couldn't cd to screens_dir.\n$!\n";
   }
   $cwd = cwd;
   if ( $screens_dir ne $cwd ) {
      die "Fatal error in PHASE_2: Couldn't cd to screens_dir.\n$!\n";
   }

   # Get fresh list of "*.png" file names:
   my @names2 = <*.png>;
   my $num2 = scalar @names2;

   # Set file permissions of screenshots so that user and group can read and write but others can read only:
   for my $name2 (@names2) {
      chmod 0664, $name2
      or warn "Warning: Couldn't update permissions on file \"$name2\" in screens_dir.\n$!\n";
   }

   # BREAKPOINT 2: If debugging, run sanity checks; if debug level is 2, exit here:
   if ( $Db )
   {
      say STDERR '';
      say STDERR 'At breakpoint 2, before renaming screenshots.';
      say STDERR "Number of files in screens_dir after moving from program_dir = $num2";
      if ( 2 == $Db ) {exit 222}
   }

   say STDOUT '';
   say STDOUT 'Now canonicalizing names of screenshots....';
   for my $name2 (@names2) {
      # Skip current file if it doesn't have a valid original-style TTR screenshot name:
      if ( $name2 !~ m/$ttrw_original/ ) {
         next;
      }

      # Get new file name:
      my $new_name = make_new_name($name2);

      # Print warning and skip current file if it couldn't be renamed:
      if ( '***ERROR***' eq $new_name ) {
         warn "Warning: File \"$name2\" couldn't be renamed to \"$new_name\";"
             ."skipping this file and moving on to next.\n";
         next;
      }

      # Print warning and skip current file if a file with the new name already exists in screens_dir:
      if ( -e $new_name ) {
         warn "Warning: A file with proposed new name \"$new_name\" already exists in screens_dir;\n"
             ."skipping this file and moving on to next.\n";
         next;
      }

      # If debugging, simulate rename:
      if (3 == $Db) {
         say "Would have renamed \"$name2\" to \"$new_name\".";
      }

      # Otherwise, attempt to rename file:
      else {
         rename($name2, $new_name)
         and say  "Renamed \"$name2\" to \"$new_name\"."
         or  warn "Error: Failed to rename \"$name2\" to \"$new_name\".";
      } # end else (rename file)
   } # end for (each file)
   say STDOUT 'Finished canonicalizing names of screenshots.';

   # Return success code 1 to caller:
   return 1;
} # end sub PHASE_2

# =========================================================================================================
# PHASE 3: File Screenshots By Date:
sub PHASE_3 {
   # Enter screenshots directory, if we're not already there:
   my $cwd = cwd;
   if ( $screens_dir ne $cwd ) {
      chdir $screens_dir
      or die "Fatal error in PHASE_3: Couldn't cd to screens_dir.\n$!\n";
   }
   $cwd = cwd;
   if ( $screens_dir ne $cwd ) {
      die "Fatal error in PHASE_3: Couldn't cd to screens_dir.\n$!\n";
   }

   # Get fresh list of "*.png" file names:
   my @names3 = <*.png>;
   my $num3 = scalar @names3;

   # BREAKPOINT 3: If debugging, run sanity checks; if debug level is 3, exit here:
   if ( $Db )
   {
      say STDERR '';
      say STDERR 'At Breakpoint 3, before filing files by date.';
      say STDERR "Number of files in screens_dir after renaming = $num3";
      if ( 3 == $Db ) {exit 333}
   }

   say STDOUT '';
   say STDOUT 'Now filing screenshots by date....';
   foreach my $name3 (@names3) {
      # Skip current file if it doesn't match "renamed file" regexp:
      if ( $name3 !~ m/$ttrw_renamed/ ) {
         next;
      }

      # Get prefix, label, date, time, and id; if anything is out-of-range, print warning and skip file:
      my $prefix = $name3 =~ s/\.png$//r;
      my ($label, $date, $time, $idst) = split /_/, $prefix;
      if (     !defined($label)   || !($label   =~ m/^ttr-screenshot$/          )
            || !defined($date)    || !($date    =~ m/^\d{4}-\d{2}-\d{2}-\pL{3}$/)
            || !defined($time)    || !($time    =~ m/^\d{2}-\d{2}-\d{2}$/       )
            || !defined($idst)    || !($idst    =~ m/^\d+$/                     ) ) {
         say STDERR "Warning: file \"$name3\" in screens_dir\n"
                   ."does not have the expected 4 underscore-separated fields;\n"
                   ."skipping this file and moving on to the next.";
         next;
      }

      # Get year, month, day, and dayname; if anything is out-of-range, print warning and skip file:
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
         say STDERR "Would have moved file \"$name3\" from screens_dir to \"$mnth_dir\".";
      }

      # Otherwise, attempt to move the current file, after assuring needed directories actually do exist,
      # and after assuring that there is no file by this name in the destination directory:
      else {
         if ( ! -e $year_dir ) {die "Error: directory \"$year_dir\" in screens_dir does not exist.    \n$!\n"}
         if ( ! -d $year_dir ) {die "Error: directory \"$year_dir\" in screens_dir is not a directory.\n$!\n"}
         if ( ! -e $mnth_dir ) {die "Error: directory \"$mnth_dir\" in screens_dir does not exist.    \n$!\n"}
         if ( ! -d $mnth_dir ) {die "Error: directory \"$mnth_dir\" in screens_dir is not a directory.\n$!\n"}

         # Print warning and skip current file if a duplicate exists in the destination:
         if ( -e "$mnth_dir/$name3" ) {
            warn "Warning: a duplicate of \"$name3\" exists in mnth_dir;\n"
                ."skipping this file and moving on to next.\n";
            next;
         }

         # Otherwise, attempt to move file:
         else {
            move($name3, "$mnth_dir/$name3")
            and say  "Moved \"$name3\" from screens_dir to \"$mnth_dir\"."
            or  warn "Error: Failed to move \"$name3\" from screens_dir to \"$mnth_dir\".\n$!\n";
         } # end else no duplicate exists
      } # end else attempt to move file
   } # end move each renamed file from screens_dir to mnth_dir
   say STDOUT 'Finished filing screenshots by date.';

   # Announce number of png files remaining in root of screens_dir:
   my @names4 = <*.png>;
   my $num4 = scalar @names4;
   say "\nNumber of png files in root of screens_dir after filing-by-date: $num4";

   # Return success code 1 to caller:
   return 1;
} # end sub PHASE_3

sub help {
   print ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "aggregate-toontown-screenshots.pl". This program does 3 things:

   1. For eash screenshot in your Toontown-Corporate-Clash program's screenshots
      directory (let's call it "program_dir" for short), this program will first
      copy that file to a subdirectory named "original" of your own personal
      screenshots directory (let's call it "screens_dir" for short), then move
      the screenshot to the rool level of screens_dir.

   2. It renames all screenshots in screens_dir to date-and-time-based names
      such that sorting the screenshots by name also sorts them chronologically.

   3. It moves all screenshots from the root of screens_dire to dated
      subdirectories of screens_dir.

   For this program to work, you MUST first specify the two directories
   "program_dir" and "screens_dir". You can do this in one of two ways:

   Method #1: Put a file named "aggregate-toontown-screenshots.ini" in the same
   directory as this script, and put your directories in there, in this syntax:

   [Locations]
   program_dir = /opt/toontown-rewritten/screenshots
   screens_dir = /home/jack/toontown-rewritten-screenshots

   Substitute-in the actual directories you're using. But don't put any comments
   on the ends of the lines giving the paths or they will be construed as being
   part of those paths.

   Method #2: Write the directories as options on your command line, using this
   syntax:

   aggregate-toontown-screenshots.pl \
   --program_dir=/opt/toontown-rewritten/screenshots \
   --screens_dir=/home/jack/toontown-rewritten-screenshots

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

   Happy Toontown-Rewritten screenshot aggregating!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
