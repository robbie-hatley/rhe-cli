#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# rename-toontown-images.pl
# Renames Toontown screenshots to a standard format such that lexical sorting = chronological sorting.
#
# Edit history:
# Fri Jan 29, 2021: Wrote first draft.
# Mon Mar 08, 2021: Heavily refactored. Now also renames TTO screenshots.
# Wed Apr 14, 2021: Expanded width to 120 characters; shorted sub names; cleaned-up formatting and comments.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Mon Nov 22, 2021: Fixed bug on line 188: "/avaname" => "/$avaname".
# Thu Nov 25, 2021: Added timestamping.
# Tue Aug 22, 2023: Upgraded from "v5.32" to "v5.36". Decreased width from 120 to 110. Got rid of CPAN module
#                   "common::sense" (antiquated). Got rid of prototypes. Now using signatures.
# Thu Aug 24, 2023: Redefined what characters may exist in options:
#                   short option = 1 hyphen , NOT followed by a hyphen, followed by [a-zA-Z0-9]+
#                   long  option = 2 hyphens, NOT followed by a hyphen, followed by [a-zA-Z0-9-=.]+
#                   I use negative look-aheads to check for "NOT followed by a hyphen". Also, dramatically
#                   improved help. Options now include help, debug, quiet, verbose, local, recurse.
#                   Got rid of "o" option on qr// (unnecessary). Put "\$" before variable names to be printed.
#                   Fixed bug in which "-" was being interpretted as "character range" instead of "hyphen",
#                   by changing "$d = [a-zA-Z0-9-=.]+" to "$d = [a-zA-Z0-9=.-]+". Dramatically simplified way
#                   in which options and arguments are printed if debugging. Removed "$" = ', '" and
#                   "$, = ', '". Got rid of "/...|.../" in favor of "/.../ || /.../" (speeds-up program).
# Fri Aug 25, 2023: Now correctly handles "annotated" file names. (Look-Ahead assertions are fun!)
#                   Now expressing execution time in seconds, to nearest millisecond.
# Sat Aug 26, 2023: Fixed pair of bugs which was interfering with checking of "final" part of name.
# Mon Aug 28, 2023: Fixed comment on final part. Improved formatting of argv. Removed "no debug" option as
#                   that's already default in ALL my programs. Changed all "$db" to "$Db".
#                   Now using "d getcwd" instead of "cwd_utf8". sub curfile() no longer calls getcwd.
# Wed Aug 14, 2024: Removed unnecessary "use" statements.
# Thu Oct 03, 2024: Got rid of Sys::Binmode and common::sense; added "use utf8".
# Mon Oct 07, 2024: Got rid of "use warnings FATAL => 'utf8';" (unnecessary).
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e", and now using "cwd" instead of "d getcwd".
# Sat May 03, 2025: Reverted to using "#!/usr/bin/env -S perl -C63" shebang and "utf8" instead of "utf8::all"
#                   and "Cwd" instead of "Cwd::utf8", for Cygwin compatibility.
##############################################################################################################

# ======= PRELIMINARIES: =====================================================================================

use v5.36;
use utf8;
use Cwd;
use Time::HiRes 'time';
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv;
sub curdire;
sub curfile;
sub stats;
sub help;

# ======= VARIABLES: =========================================================================================

# Debug?

# Settings:
my $Db        = 0; # Print diagnostics and exit?
my $Verbose   = 0; # Print stats?
my $Recurse   = 0; # Recurse subdirectories?
my $RE =
qr/^(?:tt(?:r|o)-)?screenshot(?:-_[^_]+_)?-\pL{3}-\pL{3}-\d{2}-\d{2}-\d{2}-\d{2}-\d{4}-\d+\.(?:jpg|png)$/;

# Counters:
my $direcount = 0; # Count of directories processed by curdire().
my $filecount = 0; # Count of files processed by curfile().
my $malfcount = 0; # Count of files skipped because they have malformed names (# of parts is other-than 10).
my $oldfcount = 0; # Count of old-format (Wed-Aug-27tto and/or ttr screenshot files found.
my $noavcount = 0; # Count of files skipped because there was no name available that could be used.
my $simucount = 0; # Count of simulated  file renames.
my $failcount = 0; # Count of failed     file renames.
my $renacount = 0; # Count of successful file renames.

# Hashes:
my %Months =
(
   Jan => '01',
   Feb => '02',
   Mar => '03',
   Apr => '04',
   May => '05',
   Jun => '06',
   Jul => '07',
   Aug => '08',
   Sep => '09',
   Oct => '10',
   Nov => '11',
   Dec => '12',
);

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   my $t0 = time;
   argv;
   my $pname = get_name_from_path($0);
   if ( $Verbose >= 1 ) {
      say STDERR '';
      say STDERR "Now entering program \"$pname\".";
      say STDERR "\$Db        = $Db      ";
      say STDERR "\$Verbose   = $Verbose ";
      say STDERR "\$Recurse   = $Recurse ";
      say STDERR "\$RE        = $RE  ";
   }

   $Recurse and RecurseDirs {curdire} or curdire;

   stats;
   my $et = time - $t0;
   if ( $Verbose >= 1 ) {
      say    STDERR '';
      say    STDERR "Now exiting program \"$pname\".";
      printf STDERR "Execution time was %.3f seconds.\n", $et;
   }
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS =============================================================================

sub argv {
   # ---------------------------------------------------------------------------------------------------------
   # Get Options:
   my @opts = ()            ; # options
   my $s = '[a-zA-Z0-9]'    ; # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]' ; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {
         /^-(?!-)$s+$/        # If we get a valid short option
      || /^--(?!-)$d+$/       # or a valid long option,
      and push @opts, $_;     # then push item to @opts
   }

   # ---------------------------------------------------------------------------------------------------------
   # Process Options:
   for ( @opts ) {
      /^-$s*h/ || /^--help$/     and help and exit 777 ;
      /^-$s*e/ || /^--debug$/    and $Db      =  1     ;
      /^-$s*q/ || /^--quiet$/    and $Verbose =  0     ; # DEFAULT
      /^-$s*v/ || /^--verbose$/  and $Verbose =  1     ;
      /^-$s*l/ || /^--local$/    and $Recurse =  0     ; # DEFAULT
      /^-$s*r/ || /^--recurse$/  and $Recurse =  1     ;
   }
   if ( $Db ) {
      say STDERR '';
      say STDERR "\$opts = (", join(', ', map {"\"$_\""} @opts), ')';
   }

   # ---------------------------------------------------------------------------------------------------------
   # Return Success Code 1 To Caller:
   return 1;
} # end sub argv

sub curdire {
   # Increment directory counter:
   ++$direcount;

   # Get and announce current working directory:
   my $curdir = d getcwd;
   say '';
   say "Directory # $direcount: $curdir";
   say '';

   # Get list of Regular files matching $RE (ie, old-format Toontown screenshots) in current directory:
   my $curdirfiles = GetFiles($curdir, 'F', $RE);

   # Iterate through these files and send each one to curfile:
   foreach my $file (@$curdirfiles) {curfile($file)}

   return 1;
} # end sub curdire

sub curfile ($file) {
   # Increment file counter:
   ++$filecount;

   my $path = $file->{Path};
   my $dir  = get_dir_from_path($path);
   my $name = $file->{Name};
   my $pref = denumerate_file_name(get_prefix($name));
   my $suff = get_suffix($name);
   my $n;

   # Get parts from prefix. This is tough, because we can't just split on "-", because any annotation may have
   # hyphens in it. And we can't do varible-width look-behinds. But we can look for hyphens with either 0 or 2
   # underscores to their right:
   my @parts = split /-(?=[^_]+$)|-(?=[^_]*_[^_]+_[^_]+$)/, $pref;

   # Skip this file if number of parts is < 9 or > 11:
   $n = scalar(@parts);
   if ( $n < 9 || $n > 11 ) {
      ++$malfcount;
      say "Wrong # of parts ($n): \"$name\"";
      return;
   }

   # If $parts[0] is "screenshot", unshift 'tto' to @Parts:
   if ( 'screenshot' eq $parts[0] ) {
      unshift @parts, 'tto';
   }

   # If part 2 is an annotation, remove its final "_", change " " to "-",  and tack it onto end of final part:
   if ( $parts[2] =~ m/^_[^_]+_$/ ) {
      my $note   = ((splice @parts, 2, 1));
      $note =~ s/_$//;
      $note =~ s/ /-/g;
      my $serial = pop @parts;
      my $final  = $serial.$note;
      push @parts, $final;
   }

   # REALITY CHECK!!! DO WE HAVE THE PARTS WE THINK WE DO???
   # WE SHOULD HAVE EXACTLY 10 PARTS.
   # CHECK ALL 10 PARTS TO MAKE SURE THEY ARE WHAT WE EXPECT:

   # We should now have exactly 10 parts:
   $n = scalar(@parts);
   if ( 10 != $n ) {
      ++$malfcount;
      say "Not 10 parts: \"$name\"";
      return;
   }

   # Skip this file if part 0 isn't "tto" or "ttr":
   if ( 'tto' ne $parts[0] && 'ttr' ne $parts[0] ) {
      ++$malfcount;
      say "Not tto or ttr: \"$name\"";
      return;
   }

   # Skip this file if part 1 isn't "screenshot":
   if ( 'screenshot' ne $parts[1] ) {
      ++$malfcount;
      say "No screenshot: \"$name\"";
      return;
   }

   # Skip this file if part 2 isn't dow:
   if ( $parts[2] !~ m/^(?:Sun|Mon|Tue|Wed|Thu|Fri|Sat)$/ ) {
      ++$malfcount;
      say "No dow: \"$name\"";
      return;
   }

   # Skip this file if part 3 isn't month:
   if ( $parts[3] !~ m/^(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)$/ ) {
      ++$malfcount;
      say "No month: \"$name\"";
      return;
   }

   # Skip this file if part 4 isn't valid dom:
   if ( $parts[4] !~ m/^(?:0[1-9]|1[0-9]|2[0-9]|3[0-1])$/ ) {
      ++$malfcount;
      say "No dom: \"$name\"";
      return;
   }

   # Skip this file if part 5 isn't valid hour:
   if ( $parts[5] !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/ ) {
      ++$malfcount;
      say "No hour: \"$name\"";
      return;
   }

   # Skip this file if part 6 isn't valid minutes:
   if ( $parts[6] !~ m/^[0-5][0-9]$/ ) {
      ++$malfcount;
      say "No minutes: \"$name\"";
      return;
   }

   # Skip this file if part 7 isn't valid seconds:
   if ( $parts[7] !~ m/^[0-5][0-9]$/ ) {
      ++$malfcount;
      say "No seconds: \"$name\"";
      return;
   }

   # Skip this file if part 8 isn't valid year (2000-2999):
   if ( $parts[8] !~ m/^2[0-9][0-9][0-9]$/ ) {
      ++$malfcount;
      say "No year: \"$name\"";
      return;
   }

   # Skip this file if part 9 isn't digits followed by maybe an annotation:
   if ( $parts[9] !~ m/^\d+(?:_[^_]+)?$/ ) {
      ++$malfcount;
      say "No final: \"$name\"";
      return;
   }

   # If we get to here without returning, we have a valid old-format Toontown screenshot,
   # so increment $oldfcount and get attributes from parts:
   ++$oldfcount;
   my $game    = $parts[0];          # "tto" or "ttr"
   my $ss      = $parts[1];          # "screenshot"
   my $year    = $parts[8];          # eg, "2007"
   my $month   = $Months{$parts[3]}; # eg, "09"
   my $day     = $parts[4];          # eg, "30"
   my $dow     = $parts[2];          # eg, "Sun"
   my $hour    = $parts[5];          # eg, "01"
   my $min     = $parts[6];          # eg, "05"
   my $sec     = $parts[7];          # eg, "33"
   my $final   = $parts[9];          # eg, "70299_me at front door"

   my $newpref = $game    . '-' . $ss                              . '_'
               . $year    . '-' . $month . '-' . $day . '-' . $dow . '_'
               . $hour    . '-' . $min   . '-' . $sec              . '_'
               . $final;

   my $newname = $newpref . $suff;

   my $newpath = path($dir, $newname);

   # If $newpath already exists in $dir, we need to file an available enumerated name:
   if ( -e e $newpath ) {
      my $avaname = find_avail_enum_name($newname, $dir);
      # If we failed to find an available name, skip this file:
      if ('***ERROR***' eq $avaname) {
         ++$noavcount;
         say "No available name: \"$name\"";
         return;
      }
      # Otherwise, make new path based on $avaname:
      else {
         $newpath = path($dir,$avaname);
      }
   }

   # If debugging, simulate rename:
   if ($Db) {
      ++$simucount;
      say "Simulated rename: \"$name\" => \"$newname\"";
      return;
   }

   # Otherwise, attempt rename:
   else {
      if ( rename_file($path, $newpath) ) {
         ++$renacount;
         say "Rename succeeded: \"$name\" => \"$newname\"";
         return;
      }
      else {
         ++$failcount;
         say "ERROR: Rename failed: $path to $newpath.\n";
         return;
      }
   }

   # We can't possibly get here.

   # But if we do, then print some cryptic shit to make people say "WTF???":

   print ((<<'   END_OF_TWILIGHT_ZONE') =~ s/^   //gmr);

   Back, he spurred like a madman, shrieking a curse to the sky,
   With the white road smoking behind him and his rapier brandished high.
   Blood red were his spurs in the golden noon; wine-red was his velvet coat;
   When they shot him down on the highway,
      Down like a dog on the highway,
   And he lay in his blood on the highway, with a bunch of lace at his throat.

   END_OF_TWILIGHT_ZONE
   return 666;
} # end sub curfile

sub stats {
   if ( $Db || $Verbose >= 1 ) {
      say '';
      printf("Navigated %6d directories.\n",                      $direcount);
      printf("Processed %6d files.\n",                            $filecount);
      printf("Endured   %6d files with malformed names.\n",       $malfcount);
      printf("Found     %6d old-format Toontown screenshots.\n",  $oldfcount);
      printf("Endured   %6d files with no available name.\n",     $noavcount);
      printf("Simulated %6d file renames.\n",                     $simucount);
      printf("Failed    %6d file rename attempts.\n",             $failcount);
      printf("Renamed   %6d files.\n",                            $renacount);
   }
   return 1;
} # end sub stats

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "rename-toontown-images.pl". This program renames all
   Toontown Rewritten screenshots in the current directory (and all subdirectories
   if a -r or --recurse option is used) from their original format to a format
   in which sorting by name also constitutes sorting by date.

   -------------------------------------------------------------------------------
   Command Lines:
   program-name.pl -h | --help    (to print this help and exit)
   program-name.pl [options]      (to rename Toontown images  )

   -------------------------------------------------------------------------------
   Description of options:

   Option:            Meaning:
   -h or --help       Print this help and exit.
   -e or --debug      Print diagnostics & simulate renames.
   -q or --quiet      DON'T print stats.                          (DEFAULT)
   -v or --verbose    DO    print stats.
   -l or --local      Don't recurse subdirectories.               (DEFAULT)
   -r or --recurse    Do    recurse subdirectories.

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively process items.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: herlvq.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of arguments:

   This program ignores all arguments.

   "Going DOWN, sir!"

   Happy Toontown image renaming!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
