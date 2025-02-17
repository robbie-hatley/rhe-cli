#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# day-of-week.pl
# Prints day-of-week for dates from 125 million BC to 125 million CE, Gregorian or Julian.
# Dates must be entered as three integer command-line arguments in the order "year, month, day".
# To enter CE dates, use positive year numbers (eg,  "1974" for 1974CE).
# To enter BC dates, use negative year numbers (eg, "-5782" for 5782BC).
# By default, dates entered will be construed as being Gregorian, but if a -j or --julian option is used,
# the input date will be construed as being Julian. The output will be to STDOUT and will consist of both
# Gregorian and Julian dates in "Wednesday December 27, 2017" format. Thus this program serves not-only
# to print day-of-week, but also as a Gregorian-to-Julian and Julian-to-Gregorian convertor.
#
# Usage examples:
# %day-of-week.pl 1974 8 14
# Gregorian = Wednesday August 14, 1974CEG
# Julian    = Wednesday August  1, 1974CEJ
# %day-of-week.pl 1490 3 18 -j
# Gregorian = Thursday March 27, 1490CEG
# Julian    = Thursday March 18, 1490CEJ
#
# WARNING: this program is fully capable of specifying Gregorian dates for times in which the Gregorian
# calendar did not yet exist (or was not yet in widespread use in English-speaking countries), and Julian
# dates for times in which the Julian calendar was no-longer in widespread use. If in doubt, use a -w or
# --warnings option; this program will print appropriate warnings such "proleptic" (meaning "not in-use
# at that time"), "English" (the English-speaking world was still using Julian for almost 2 centuries after
# the rest of the world had upgraded to Gregorian), or "Julian" (usage of Julian after late 1752 is
# anachronistic).
#
# NOTE: There WAS NO "Year Zero" in either the Julian OR Gregorian calendars. So what happens if you enter 0
# as year number? Well, you no-clip out of ordinary reality and into Year Zero, The Year That Stretches.
# Exactly what will happen is a bit random, but try it and see.
#
# Author: Robbie Hatley.
#
# Edit history:
# Tue Dec 23, 2014? Started  writing it. (This was dated "Tue Dec 23, 2016", but no such date exists.)
# Wed Dec 24, 2014? Finished writing it. (This was dated "Wed Dec 24, 2016", but no such date exists.)
# Sat Apr 16, 2016: Now using -CSDA; also added some comments.
# Sun Jul 23, 2017: Commented-out unnecessary module inclusions and clarified some puzzling comments. Also,
#                   converted from utf8 back to ASCII.
# Wed Dec 27, 2017: Clarified comments.
# Mon Apr 16, 2018: Started work on expanding the date range from 1899-12-31 -> 9999-12-31
#                                                             to  0001-01-01 -> 9999-12-31
# Wed May 30, 2018: Completed date range expansion.
# Wed Oct 16, 2019: Now gives DOW for both Julian and Gregorian dates.
# Thu Feb 13, 2020: Refactored main() and day_of_week(), implemented emit_despale(), and added "day of week
#                   from elapsed time" feature. (Next up: Gregorian <=> Julian)
# Fri Feb 14, 2020: Cleaned-up some comments.
# Sat Feb 15, 2020: Now gives day of week and both Gregorian and Julian dates for all requests. I also muted
#                   warnings unless user requests them. The minimum date is now Dec 30, 1BCG = Jan 1, 1CEJ,
#                   and the maximum date is now unlimited (though, for dates much past 1000000CEG, the
#                   computation time becomes unworkable). Also, removed "input elapsed time", as it's useless.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Thu Sep 14, 2023: Reduced width from 120 to 110. Corrected impossible dates for "starting writing it" and
#                   "finished writing it" above. Removed CPAN module "common::sense" (antiquated). Reverted
#                   from unicode/UTF-8 to ASCII. Removed CPAN module "Sys::Binmode" (unneeded). Upgraded from
#                   "v5.32" to "v5.38". Not using any other pragmas. Got rid of all prototypes. Now using
#                   signatures. Got rid of all given/when. Refactored to use 00:00:00UTC on 1 1 1 Julian as
#                   "reference instant of time". "Elapsed time" is now 0 instead of 1 for that date.
#                   Clarified date range as being "1 1 1 -j" through "5000000 12 31 -j", which is the same as
#                   "0 12 30" through "5000103 9 1" Gregorian. Re-wrote help(), both improving formatting and
#                   adding new options and greatly-clarified limits on dates. I also added [-e|--debug] and
#                   [-g|--gregorian] options.
# Fri Sep 15, 2023: "Warnings" now come in 3 flavors: "Proleptic", "English", and "Anachronistic".
# Tue Sep 19, 2023: Started work expanding the range to 200 million years centered around the day 1/1/1CEJ.
# Wed Sep 20, 2023: Completed upgrade: date range is now 100 million BC to 100 million CE. I chose this limit
#                   due to computation time running over 1 minute for dates outside that range, even on a fast
#                   computer. Perl 32-bit signed integer range actually allows dates of +- 2 billion; however,
#                   computation time would be in the hours or days, and there were no multi-cell life forms
#                   on earth in 2 billion BC anyway, so who cares what day-of-week 2 billion BC is? At least
#                   in 100 million BC, humans existed, though at that time we were small furry rodents.
# Sat Sep 30, 2023: Converted back to UTF-8, and added-in a few more pieces of poetry.
# Thu Aug 15, 2024: -C63.
##############################################################################################################

use v5.38;
use utf8;

# ======= SUBROUTINE PRE-DECLARATIONS ========================================================================

sub argv           ; # Process @ARGV and set settings accordingly.
sub days_per_year  ; # How many days in given whole year?
sub days_per_month ; # How many days in given whole month?
sub is_leap_year   ; # Is given year a leap year?
sub elapsed_time   ; # Full days elapsed from 00:00:00UTC on morning of Sat Jan 1, 1CEJ, to given date.
sub prev_year      ; # Same time last year.
sub prev_mnth      ; # Same time last month.
sub prev_daay      ; # Same time last day.
sub emit_despale   ; # Given full days elapsed since 00:00:00UTC Sat Jan 1 1CEJ, determine date.
sub day_of_week    ; # Determine day-of-week for a given date.
sub warnings       ; # Print appropriate warnings if use used a -w or --warnings option.
sub proleptic      ; # Print "proleptic use of Gregorian"  message.
sub english        ; # Print "English transition period"   message.
sub anachronistic  ; # Print "anachronistic use of Julian" message.
sub error          ; # Print error message.
sub help           ; # Print help  message.
sub year_zero      ; # The Year That Stretches.
sub second         ; # You really shouldn't have voted for Donald Trump.
sub invictus       ; # You had the power not to.
sub highway        ; # No one stole that from you.
sub swagman        ; # You could have shown some backbone.
sub nazgûl         ; # But instead, you caved-in to evil.
sub cthulhu        ; # Now, you will go insane.

# ======= PAGE-GLOBAL LEXICAL VARIABLES: =====================================================================

# Settings:         # Meaning of setting:          Range:   Meaning of default:
my $Db        = 0 ; # Print diagnostics?           bool     Don't print diagnostics.
my $Warnings  = 0 ; # Emit calendar use warnings?  bool     Don't print calendar-use warnings.
my $A_Y       = 0 ; # Year  from CL arguments.     pos int  "not-yet-initialized".
my $A_M       = 0 ; # Month from CL arguments.     pos int  "not-yet-initialized".
my $A_D       = 0 ; # Day   from CL arguments.     pos int  "not-yet-initialized".
my $Julian    = 0 ; # Construe input as Julian?    bool     Construe input as Gregorian.
my $Sector    = 0 ; # What time sector are we in?  int      Base time is 00:00:00UTC, 1/1/1CE Julian

my @SecElapsed
   = ();

my @SecDowOffs
   = ();

my @DaysOfWeek
   = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);

my @Months
   = qw(January   February  March     April     May       June
        July      August    September October   November  December);

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Declare all local variables for use in main only here:
   my $G_Y     ; # Gregorian year.
   my $G_M     ; # Gregorian month.
   my $G_D     ; # Gregorian day.
   my $J_Y     ; # Julian year.
   my $J_M     ; # Julian month.
   my $J_D     ; # Julian day.
   my $Elapsed ; # Elapsed time.
   my $BCJ     ; # Julian    era string ("BCJ" or "CEJ").
   my $BCG     ; # Gregorian era string ("BCG" or "CEG").

   # Process @ARGV and set settings and arguments accordingly:
   argv;

   if ( $Db ) {
      say "\$Julian = $Julian";
   }

   # If user specified that input date is Julian, Convert from Julian to Gregorian:
   if ( $Julian ) {
      $J_Y = $A_Y;
      $J_M = $A_M;
      $J_D = $A_D;
      $Elapsed = elapsed_time($J_Y, $J_M, $J_D, 1);
      ($G_Y, $G_M, $G_D) = emit_despale($Elapsed, 0);
   }

   # Otherwise, construe input as Gregorian and convert to Julian:
   else {
      $G_Y = $A_Y;
      $G_M = $A_M;
      $G_D = $A_D;
      $Elapsed = elapsed_time($G_Y, $G_M, $G_D, 0);
      ($J_Y, $J_M, $J_D) = emit_despale($Elapsed, 1);
   }

   # Calculate day of week from elapsed time since 00:00:00UTC on the morning of Dec 31, 1BCJ:
   my $DayOfWeek = day_of_week($Elapsed);

   # Negative or zero year numbers mean BC, so invert them and add 1 and set era strings accordingly:
   if ( $J_Y < 1 ) {
      $J_Y = 1 - $J_Y;
      $BCJ = 'BCJ';
   }
   else {
      $BCJ = 'CEJ';
   }
   if ( $G_Y < 1 ) {
      $G_Y = 1 - $G_Y;
      $BCG = 'BCG';
   }
   else {
      $BCG = 'CEG';
   }

   # Print day-of-week and Gregorian and Julian dates:
   printf( "Gregorian = %-9s %-9s %2d, %7d%s\n", $DayOfWeek, $Months[$G_M-1], $G_D, $G_Y, $BCG );
   printf( "Julian    = %-9s %-9s %2d, %7d%s\n", $DayOfWeek, $Months[$J_M-1], $J_D, $J_Y, $BCJ );

   # Depending on which calendar was actually IN-USE on the given date, print a warning message if user used
   # a -w or --warnings option:
   if ($Warnings) {
      warnings($A_Y, $A_M, $A_D, $Julian);
   }

   # Return success code 0 to operating system:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub argv {
   # Get options and arguments:
   my @opts = ();          # options
   my @args = ();          # arguments
   my $s = '[a-zA-Z]';     # single-hyphen allowable chars (English letters only)
   my $d = '[a-zA-Z]';     # double-hyphen allowable chars (English letters only)
   for ( @ARGV ) {
         ( /^-$s+$/        # If we get a valid short option
      ||  /^--$d+$/ )      # or a valid long option,
      and push @opts, $_   # then push item to @opts
      or  push @args, $_;  # else push item to @args.
   }

   # Process options:
   for ( @opts ) {
      /^-$s*h/ || /^--help$/      and help and exit 777 ;
      /^-$s*e/ || /^--debug$/     and $Db       =  1    ;
      /^-$s*g/ || /^--gregorian$/ and $Julian   =  0    ; # DEFAULT
      /^-$s*j/ || /^--julian$/    and $Julian   =  1    ;
      /^-$s*w/ || /^--warning$/   and $Warnings =  1    ;
   }
   if ( $Db ) {
      say STDERR '';
      say STDERR "\$opts = (", join(', ', map {"\"$_\""} @opts), ')';
      say STDERR "\$args = (", join(', ', map {"\"$_\""} @args), ')';
   }

   # Process arguments:
   my $NA = scalar(@args); # Get number of arguments.
   if (3 != $NA) {         # If number of arguments isn't 3,
      error;               # print error message,
      help;                # and print help message,
      exit 666;            # and return The Number Of The Beast.
   }

   # Store arguments in variables:
   $A_Y = $args[0];
   $A_M = $args[1];
   $A_D = $args[2];

   # If user entered the non-existent year "0", no-clip user into The Year That Stretches:
   if ( 0 == $A_Y ) {
      year_zero; exit 888;
   }

   # If year is out-of-range, abort:
   if ( $A_Y < -125000000 || $A_Y > 125000000 ) {
      error('Year is out-of-range.'); help; exit 666;
   }

   # If month is out-of-range, abort:
   if ( $A_M < 1 || $A_M > 12 ) {
      error('Month is out-of-range.'); help; exit 666;
   }

   # If non-existent leap day was given, abort:
   if ( 2==$A_M && 29==$A_D && 28==days_per_month($A_Y, $A_M, $Julian) ) {
      error('Non-existent leap day.'); help; exit 666;
   }

   # If day is out-of-range, abort:
   if ( $A_D < 1 || $A_D > days_per_month($A_Y, $A_M, $Julian) ) {
      error('Day is out-of-range.'); help; exit 666;
   }

   # VITALLY IMPORTANT: If year is negative, increase it by one, because our year numbers MUST BE 0-indexed
   # in order to calculate leap years, but the concept of "zero" was not yet in common use in the year 1BC,
   # so they called it "1BC" instead of "0CE" as they should have:
   if ( $A_Y < 0 ) {
      ++$A_Y;
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

sub is_leap_year ($year, $julian) {
   # Julian Calendar:
   if ($julian) {
      if (0 == $year%4) {return 1;}
      else              {return 0;}
   }
   # Gregorian Calendar:
   else {
      if    ( 0 == $year%4 && 0 != $year%100 ) {return 1;}
      elsif ( 0 == $year%400                 ) {return 1;}
      else                                     {return 0;}
   }
} # end sub is_leap_year

sub days_per_year ($year, $julian) {
   my $dpm = 365;
   if (is_leap_year($year, $julian)) {++$dpm;}
   return $dpm;
} # end sub days_per_year

sub days_per_month ($year, $month, $julian) {
   state @dpm = (0, 31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
   if ( 2 == $month ) { return (is_leap_year($year, $julian) ? 29 : 28);}
   else {return $dpm[$month];}
} # end sub days_per_month

# Calculate midnights transited-through from 00:00:00.1UTC Sat Jan 1 1CEJ to 00:00:00.1UTC on given date:
sub elapsed_time ($year, $month, $day, $julian) {
   # This sub acts by counting time forward or backwards from Jan 1, 1CE, Julian OR Gregorian. However,
   # Jan 1 1CEJ is Dec 30 1BCG, so if we're using Gregorian, we need to start with an offset of +2 days,
   # because in Gregorian, our "zero reference time" is 00:00:00.1UTC on Dec 30 1BCG, so Jan 1 1CEG already
   # has an elapsed time of +2 days to start with:
   my $elapsed = $julian ? 0 : 2;

   # BC:
   if ( $year < 1 ) {
      # Subtract-out days from whole years which have unelapsed from 00:00:00UTC on Jan 1, 1CEJ
      # down-to (but not including) current year:
      if ( $year < 0 ) {
         foreach my $passing_year ( ($year + 1) .. 0 ) {
            $elapsed -= days_per_year($passing_year, $julian);
         }
      }

      # Next, subtract-out days from whole months which have unelapsed this year down-to (but not including)
      # the current month:
      if ( $month < 12 ) {
         foreach my $passing_month ( ($month + 1) .. 12 ) {
            $elapsed -= days_per_month($year, $passing_month, $julian);
         }
      }

      # Finally, substract-out days which have unelapsed in current month down-to AND INCLUDING today:
      $elapsed -= (days_per_month($year, $month, $julian) - $day + 1);
   }

   # CE:
   else {
      # Add-in days from whole years which have elapsed from 00:00:00UTC on Jan 1, 1CEJ
      # up-to (but not including) current year:
      if ($year > 1) {
         foreach my $passing_year ( 1 .. $year - 1 ) {
            $elapsed += days_per_year($passing_year, $julian);
         }
      }

      # Next, add-in days from whole months which have elapsed this year up-to (but not including) the current
      # month, while taking
      if ( $month > 1 ) {
         foreach my $passing_month ( 1 .. $month - 1 ) {
            $elapsed += days_per_month($year, $passing_month, $julian);
         }
      }

      # Finally, add-in days which have elapsed in current month up-to (but not including) today.
      # Subtract 1 from $day because it's 1-indexed and we need 0-indexed. For example, on June 1 1974,
      # 0 full days have elapsed so far in June, because today hasn't "elapsed" yet:
      $elapsed += ($day - 1); #
   }

   # Return elapsed time in full days since 00:00:00UTC, Sat Jan 01, 1CEJ:
   if ( $Db ) {say "DBM elapsed_time end: \$elapsed = $elapsed"}
   return $elapsed;
} # end sub elapsed_time

# Same time last year:
sub prev_year ($year, $julian) {
   my ($pyear, $dpy);
   $pyear = $year - 1;
   $dpy = days_per_year($pyear, $julian);
   return ($pyear, $dpy);
}

# Same time last month:
sub prev_mnth ($year, $mnth, $julian) {
   my ($pyear, $pmnth, $dpm);
   $pmnth =  1 == $mnth  ? 12 : $mnth - 1;
   $pyear = 12 == $pmnth ? $year - 1 : $year ;
   $dpm   = days_per_month($pyear, $pmnth, $julian);
   return ($pyear, $pmnth, $dpm);
}

# Same time last day:
sub prev_daay ($year, $mnth, $daay, $julian) {
   my ($pyear, $pmnth, $pdaay) = ($year, $mnth, $daay);
   --$pdaay;
   if ( 0 == $pdaay ) {
      --$pmnth;
      if ( 0 == $pmnth ) {
         $pmnth = 12;
         $pyear = $year - 1;
      }
      $pdaay = days_per_month($pyear, $pmnth, $julian);
   }
   return ($pyear, $pmnth, $pdaay);
}

# Given elapsed time in days since 00:00:00.1 Sat Jan 1 1CEJ, return date as a ($Year, $Month, $Day) list,
# in either Julian or Gregorian depending on user's request:
sub emit_despale ($elapsed, $julian) {
   my $accum = ($julian ? 0 : 2) ; # Accumulation of days elapsed or unelapsed.
   my $pyear = 0                 ; # Previous year.
   my $pmnth = 0                 ; # Previous month.
   my $pdaay = 0                 ; # Previous day.
   my $year  = 1                 ; # Current year.
   my $mnth  = 1                 ; # Current month.
   my $daay  = 1                 ; # Current day.
   my $dpy   = 0                 ; # Days per year.
   my $dpm   = 0                 ; # Days per month.

   if ( $Db ) {
      say "DBM emit_despale top: \$accum = $accum \$elapsed = $elapsed";
   }

   # If going backward in time from 00:00:00UTC on Jan 1, 1CE (Julian or Gregorian):
   if ( $elapsed < $accum ) {
      # Determine $year by subtracting-out days from whole years which have unelapsed:
      while ( ($pyear, $dpy) = prev_year($year, $julian), $accum - $dpy >= $elapsed ) {
         $accum -= $dpy;
         $year = $pyear;
         if ( $Db ) {say "DBM emit_despale rev yloop: year = $year month = $mnth day = $daay"}
         if ( $year < -130000000 ) {die "Fatal error in emit_despale(): \$year = $year.\n";}
      }

      # Determine $mnth by subtracting-out days from whole months which have unelapsed:
      while ( ($pyear, $pmnth, $dpm) = prev_mnth($year, $mnth, $julian), $accum - $dpm >= $elapsed ) {
         $accum -= $dpm;
         $year   = $pyear;
         $mnth   = $pmnth;
         if ( $Db ) {say "DBM emit_despale rev mloop: year = $year month = $mnth day = $daay"}
         if ( $mnth < 1 ) {die "Fatal error in emit_despale(): \$mnth = $mnth.\n";}
      }

      # Determine $daay by subtracting-out days in previous month which have unelapsed:
      while ( ($pyear, $pmnth, $pdaay) = prev_daay($year, $mnth, $daay, $julian), $accum > $elapsed ) {
         $accum -= 1;
         $year   = $pyear;
         $mnth   = $pmnth;
         $daay   = $pdaay;
         if ( $Db ) {say "DBM emit_despale rev dloop: year = $year month = $mnth day = $daay"}
         if ( $daay < 1 ) {die "Fatal error in emit_despale(): \$daay = $daay.\n";}
      }
   }

   # If going forward in time from 00:00:00UTC on Jan 1, 1CE (Julian or Gregorian):
   else {
      # Determine $year by adding elapsed days from whole years which have elapsed since 00:00:00UTC on
      # Saturday Jan 1, 1CEJ:
      while ( $accum + ($dpy = days_per_year($year, $julian)) <= $elapsed ) {
         $accum += $dpy;
         ++$year; if ( 0 == $year ) {$year = 1;}
         if ( $Db ) {say "DBM emit_despale fwd: \$year = $year"}
         if ( $year > 130000000 ) {die "Fatal error in emit_despale(): \$year = $year.\n";}
      }

      # Determine $mnth by adding elapsed days from whole months since last second of $year:
      while ( $accum + ($dpm = days_per_month($year, $mnth, $julian)) <= $elapsed ) {
         $accum += $dpm;
         ++$mnth;
         if ( $Db ) {say "DBM emit_despale fwd: \$mnth = $mnth"}
         if ( $mnth > 12 ) {die "Fatal error in emit_despale(): \$mnth = $mnth.\n";}
      }

      # Determine $daay by adding elapsed days since last second of $mnth:
      while ( $accum + 1 <= $elapsed ) {
         ++$accum;
         ++$daay;
         if ( $Db ) {say "DBM emit_despale fwd: \$daay = $daay"}
         if ( $daay > 31 ) {die "Fatal error in emit_despale(): \$daay = $daay.\n";}
      }
   }

   if ( $Db ) {say "DBM emit_despale end: \$accum = $accum \$elapsed = $elapsed"}
   return ($year, $mnth, $daay);
} # end sub emit_despale

sub day_of_week ($Elapsed) {
   # There are only 7 possible values for "day of week" to correspond to the infinity of all dates.
   # The day-of-week values are cycled-through from left to right, then repeated starting again at left,
   # endlessly. This is a "cyclic Abelian group".

   # Hence the only questions are, what leap-days are we using (Julian or Gregorian), and which
   # group-start-point (index 0 through 6) are we using. The group start point will be determined
   # by the "base date", which is "one day before the first date this program can handle", and by
   # the day-of-week of that "base date", and by the number of "days elapsed" which have occurred
   # after that "base day", where "days elapsed" means "midnights transitioned-through".

   # This program uses a "base time" of 00:00:00.1UTC, Saturday Jan 01, 1CEJ
   # which is equivalent to             00:00:00.1UTC, Saturday Dec 30, 1BCG
   # to calculate all dates, Julian and Gregorian. Because our zero-reference time is a Saturday (index 6),
   # to get "day of week" we need only add an offset of 6 to the "days elapsed" then apply modulo 7:
   return $DaysOfWeek[($Elapsed + 6) % 7];
} # end sub day_of_week

sub warnings ($y, $m, $d, $j) {
   if ( $Db ) {say "Debug msg in warnings(): \$y = $y  \$m = $m  \$d = $d  \$j = $j"}
   if ( !$j && ($y < 1582 || $y == 1582 && $m < 10 || $y == 1582 && $m == 10 && $d < 15) ) {
      proleptic;
   }
   if ( !$j && ($y > 1582 || $y == 1582 && $m > 10 || $y == 1582 && $m == 10 && $d > 14)
            && ($y < 1752 || $y == 1752 && $m <  9 || $y == 1752 && $m ==  9 && $d < 14) ) {
      english;
   }
   if (  $j && ($y > 1582 || $y == 1582 && $m > 10 || $y == 1582 && $m == 10 && $d >  4)
            && ($y < 1752 || $y == 1752 && $m <  9 || $y == 1752 && $m ==  9 && $d <  3) ) {
      english;
   }
   if (  $j && ($y > 1752 || $y == 1752 && $m >  9 || $y == 1752 && $m ==  9 && $d >  2) ) {
      anachronistic;
   }
   return 1;
} # end sub warnings

sub proleptic {
   print ((<<'   END_OF_PROLEPTIC') =~ s/^   //gmr);
   ###############################################################################
   # WARNING: You entered a Gregorian date which is before the Gregorian         #
   # calendar came into existence on Friday, October 15, 1582CEG (October 5,     #
   # 1582CEJ). Hence, the date you gave is a "proleptic" application of          #
   # The Gregorian Calendar to a point in time in which it did not yet exist.    #
   # People in those times used The Julian Calendar.                             #
   ###############################################################################
   END_OF_PROLEPTIC
   return 1;
} # end sub print_proleptic

sub english {
   print ((<<'   END_OF_ENGLISH') =~ s/^   //gmr);
   ###############################################################################
   # WARNING: The date you entered is during the nearly-two-century-long period  #
   # during which The English-speaking world was still using The Julian Calendar #
   # even though the rest of The World was using The Gregorian Calendar.         #
   #                                                                             #
   # Although The Gregorian Calendar took effect on Friday October 15, 1582,     #
   # The British Empire and it's colonies (including those which later became    #
   # USA) didn't adopt The Gregorian calendar until September 14, 1752. Thus     #
   # all dates in English-language literature before that date are in            #
   # The Julian Calendar.                                                        #
   #                                                                             #
   # When The British Empire adopted The Gregorian Calendar on 1752-09-14, the   #
   # date jumped from September 2, 1752 to September 14, 1752, thus seemingly    #
   # slicing 11 days out of history. The dates from Sep 3, 1752 through          #
   # Sep 13, 1752 thus do not appear in English-language literature at all.      #
   # It's not that those dates didn't exist; they did; but they were only used   #
   # in non-English-speaking countries which had already converted to Gregorian  #
   # years or centuries earlier.                                                 #
   #                                                                             #
   # So if the date you typed is in connection with the English language, it's   #
   # best expressed in Julian; whereas if it is in connection with any other     #
   # language (especially Spanish, French, or Italian), it's best expressed in   #
   # Gregorian. (Note: This prescription applies only to the time range from     #
   # Friday October 15, 1582CEG through Wednesday September 13, 1752CEG. Before  #
   # that time period, the whole world was using Julian; and after, Gregorian.)  #
   ###############################################################################
   END_OF_ENGLISH
   return 1;
} # end sub print_english

sub anachronistic {
   print ((<<'   END_OF_JULIAN') =~ s/^   //gmr);
   ###############################################################################
   # WARNING: You entered a Julian date which is after the Gregorian calendar    #
   # came into worldwide use on Thu Sep 14, 1752CEG (Thu Sep 03, 1752CEJ).       #
   # Hence, the date you gave is an "anachronistic" application of Julian to a   #
   # point in time in which it was no-longer being widely used. Literature       #
   # written on-or-after Thu Sep 14, 1752CEG nearly always uses the Gregorian    #
   # calendar. Julian after that date is mostly only used in certain religions,  #
   # most notably Christian "orthodox" churches.                                 #
   ###############################################################################
   END_OF_JULIAN
   return 1;
} # end sub print_julian

sub error ($message) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: $message

   \"day-of-week.pl\" takes exactly 3 integer arguments which must be year,
   month, and day, in that order. Use negative year numbers for BC, positive for
   CE. To specify Julian, use a -j or --julian option. (There WAS NO "year 0" in
   ANY calendar, so if you enter 0 for year, something bizarre will happen.)
   Help follows:
   END_OF_ERROR
   return 1;
} # end sub error

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to Robbie Hatley's nifty "Day Of Week" program. Given any date,
   from Sun Jan  1, 100000000 BC Julian (Sun Jul 27, 100002054 BC Gregorian)
   to   Thu Dec 31, 100000000 CE Julian (Thu Jun  4, 100002054 CE Gregorian)
   this program will tell you what day-of-week (Sun, Mon, Tue, Wed, Thu, Fri, Sat)
   that date is.

   Warning: for dates more than a few million years from 1CE, the computation
   time may be very long.

   Dates must be entered as three integers in the order "year, month, day".
   To enter CE dates, use positive year numbers (eg,  "1974" for 1974CE).
   To enter BC dates, use negative year numbers (eg, "-5782" for 5782BC).
   By default, dates entered will be construed as Gregorian, but if a -j or
   --julian option is used, the input date will be construed as Julian.
   The output will be to STDOUT and will consist of both Gregorian and Julian
   dates in "Wednesday December 27, 2017" format. Thus this program serves
   not-only to print day-of-week, but also as a Gregorian-to-Julian and
   Julian-to-Gregorian date converter.

   Note: There WAS NO "year zero" in ANY calendar, so if you enter "0" for year,
   something interesting will happen. Try it and see.

   -------------------------------------------------------------------------------
   Command lines:

   day-of-week.pl [-h | --help]              (to print this help and exit)
   day-of-week.pl [options] year month day   (to print day-of-week)

   -------------------------------------------------------------------------------
   Description of options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics.
   -g or --gregorian  Construe entered date as Gregorian (DEFAULT)
   -j or --julian     Construe entered date as Julian.
   -w or --warnings   Print "Proleptic", "English", or "Anachronistic" warnings.

   If a "-j" or "--julian" option is used, the date given will be construed
   to be Julian; otherwise, it will be construed to be Gregorian.

   If a "-w" or "--warnings" option is used, this program will warn you when you
   request a Gregorian date for a point in time in which the Gregorian calendar
   was either not in use, or not in use in the English-speaking world. Otherwise,
   no warnings will be given.

   -------------------------------------------------------------------------------
   Description Of Arguments:

   This program must be given exactly 3 arguments, which must be the year, month,
   and day for which you want day-of-week. This date must be
   from Sun Jan  1, 100000000 BC Julian (Sun Jul 27, 100002054 BC Gregorian)
   to   Thu Dec 31, 100000000 CE Julian (Thu Jun  4, 100002054 CE Gregorian)
   To enter CE dates, use positive year numbers (eg,  "1974" for 1974CE).
   To enter BC dates, use negative year numbers (eg, "-5782" for 5782BC).

   -------------------------------------------------------------------------------
   Usage Examples:

   Example 1 (Gregorian):
     input:   day-of-week.pl 1954 7 3
     output:  Gregorian = Saturday July 3, 1954CEG
              Julian    = Saturday June 20, 1954CEJ

   Example 2 (Julian):
     input:   day-of-week.pl -j 874 5 8
     output:  Gregorian = Saturday May 12, 874CEG
              Julian    = Saturday May 8, 874CEJ

   Happy day-of-week printing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help

sub year_zero {
   print ((<<'   END_OF_ZERO') =~ s/^   //gmr);

   You have no-clipped out of normal reality and into Year Zero, The Year That
   Stretches. The days of this year have no names, and their number is
   uncountable.

   You find yourself standing on what appears to be a desert heath at dusk on a
   cloudy day. Around you, as far as your eye can see, are cacti (Saguaro, Prickly
   Pear, and Cholla) and sand verbena. You see no signs of human artifacts or
   activity. You have the uneasy feeling that this place isn't even real.
   Maybe you will eventually be able to no-clip back to normal reality, or maybe
   not. Either way, you may be here a long time, so you might as well enjoy your
   stay.

   As you look around this deserted place, an odd though occurs to you: "I wish I
   had something to read." No sooner do you think that than a warm dry wind blows
   a sheet of parchment onto your feet. You pick it up. It has a poem written on
   it. It appears to have been written in cursive script with black ink and a
   quill pen. You begin to read.
   END_OF_ZERO

   my $idx = int rand 6;
   for ($idx) {
      /0/ and second;
      /1/ and invictus;
      /2/ and highway;
      /3/ and swagman;
      /4/ and nazgûl;
      /5/ and cthulhu;
   }

   return 1;
} # end sub year_zero

sub second {
   print ((<<'   END_OF_SECOND') =~ s/^   //gmr);

   -------------------------------------------------------------------------------

   The Second Coming
   by William Butler Yeats

   Turning and turning in the widening gyre
   The falcon cannot hear the falconer;
   Things fall apart; the centre cannot hold;
   Mere anarchy is loosed upon the world,
   The blood-dimmed tide is loosed, and everywhere
   The ceremony of innocence is drowned;
   The best lack all conviction, while the worst
   Are full of passionate intensity.

   Surely some revelation is at hand;
   Surely the Second Coming is at hand.
   The Second Coming! Hardly are those words out
   When a vast image out of Spiritus Mundi
   Troubles my sight: somewhere in sands of the desert
   A shape with lion body and the head of a man,
   A gaze blank and pitiless as the sun,
   Is moving its slow thighs, while all about it
   Reel shadows of the indignant desert birds.
   The darkness drops again; but now I know
   That twenty centuries of stony sleep
   Were vexed to nightmare by a rocking cradle,
   And what rough beast, its hour come round at last,
   Slouches towards Bethlehem to be born?

   -------------------------------------------------------------------------------

   You drop the poem with a feeling of guilt and despair, and you realize that you
   shouldn't have voted for Donald Trump in the last election.
   END_OF_SECOND
} # end sub second

sub invictus {
   print ((<<'   END_OF_INVICTUS') =~ s/^   //gmr);

   -------------------------------------------------------------------------------

   Invictus
   by William Ernest Henley

   Out of the night that covers me,
      Black as the pit from pole to pole,
   I thank whatever gods may be
      For my unconquerable soul.

   In the fell clutch of circumstance
      I have not winced nor cried aloud.
   Under the bludgeonings of chance
      My head is bloody, but unbowed.

   Beyond this place of wrath and tears
      Looms but the Horror of the shade,
   And yet the menace of the years
      Finds and shall find me unafraid.

   It matters not how strait the gate,
      How charged with punishments the scroll,
   I am the master of my fate,
      I am the captain of my soul.

   -------------------------------------------------------------------------------

   You look around you with new appreciation of the landscape. This place may be
   Hell, but it's YOUR Hell, and you realize you can make of it whatever you want.
   END_OF_INVICTUS
} # end sub invictus

sub highway {
   print ((<<'   END_OF_HIGHWAY') =~ s/^   //gmr);

   -------------------------------------------------------------------------------

   The Highwayman
   By Alfred Noyes

   PART ONE

   The wind was a torrent of darkness among the gusty trees.
   The moon was a ghostly galleon tossed upon cloudy seas.
   The road was a ribbon of moonlight over the purple moor,
   And the highwayman came riding—
            Riding—riding—
   The highwayman came riding, up to the old inn-door.

   He’d a French cocked-hat on his forehead, a bunch of lace at his chin,
   A coat of the claret velvet, and breeches of brown doe-skin.
   They fitted with never a wrinkle. His boots were up to the thigh.
   And he rode with a jewelled twinkle,
            His pistol butts a-twinkle,
   His rapier hilt a-twinkle, under the jewelled sky.

   Over the cobbles he clattered and clashed in the dark inn-yard.
   He tapped with his whip on the shutters, but all was locked and barred.
   He whistled a tune to the window, and who should be waiting there
   But the landlord’s black-eyed daughter,
            Bess, the landlord’s daughter,
   Plaiting a dark red love-knot into her long black hair.

   And dark in the dark old inn-yard a stable-wicket creaked
   Where Tim the ostler listened. His face was white and peaked.
   His eyes were hollows of madness, his hair like mouldy hay,
   But he loved the landlord’s daughter,
            The landlord’s red-lipped daughter.
   Dumb as a dog he listened, and he heard the robber say—

   “One kiss, my bonny sweetheart, I’m after a prize to-night,
   But I shall be back with the yellow gold before the morning light;
   Yet, if they press me sharply, and harry me through the day,
   Then look for me by moonlight,
            Watch for me by moonlight,
   I’ll come to thee by moonlight, though hell should bar the way.”

   He rose upright in the stirrups. He scarce could reach her hand,
   But she loosened her hair in the casement. His face burnt like a brand
   As the black cascade of perfume came tumbling over his breast;
   And he kissed its waves in the moonlight,
            (O, sweet black waves in the moonlight!)
   Then he tugged at his rein in the moonlight, and galloped away to the west.

   PART TWO

   He did not come in the dawning. He did not come at noon;
   And out of the tawny sunset, before the rise of the moon,
   When the road was a gypsy’s ribbon, looping the purple moor,
   A red-coat troop came marching—
            Marching—marching—
   King George’s men came marching, up to the old inn-door.

   They said no word to the landlord. They drank his ale instead.
   But they gagged his daughter, and bound her, to the foot of her narrow bed.
   Two of them knelt at her casement, with muskets at their side!
   There was death at every window;
            And hell at one dark window;
   For Bess could see, through her casement, the road that he would ride.

   They had tied her up to attention, with many a sniggering jest.
   They had bound a musket beside her, with the muzzle beneath her breast!
   “Now, keep good watch!” and they kissed her. She heard the doomed man say—
   Look for me by moonlight;
            Watch for me by moonlight;
   I’ll come to thee by moonlight, though hell should bar the way!

   She twisted her hands behind her; but all the knots held good!
   She writhed her hands till her fingers were wet with sweat or blood!
   They stretched and strained in the darkness, and the hours crawled by like years
   Till, now, on the stroke of midnight,
            Cold, on the stroke of midnight,
   The tip of one finger touched it! The trigger at least was hers!

   The tip of one finger touched it. She strove no more for the rest.
   Up, she stood up to attention, with the muzzle beneath her breast.
   She would not risk their hearing; she would not strive again;
   For the road lay bare in the moonlight;
            Blank and bare in the moonlight;
   And the blood of her veins, in the moonlight, throbbed to her love’s refrain.

   Tlot-tlot; tlot-tlot! Had they heard it? The horsehoofs ringing clear;
   Tlot-tlot; tlot-tlot, in the distance? Were they deaf that they did not hear?
   Down the ribbon of moonlight, over the brow of the hill,
   The highwayman came riding—
            Riding—riding—
   The red coats looked to their priming! She stood up, straight and still.

   Tlot-tlot, in the frosty silence! Tlot-tlot, in the echoing night!
   Nearer he came and nearer. Her face was like a light.
   Her eyes grew wide for a moment; she drew one last deep breath,
   Then her finger moved in the moonlight,
            Her musket shattered the moonlight,
   Shattered her breast in the moonlight and warned him—with her death.

   He turned. He spurred to the west; he did not know who stood
   Bowed, with her head o’er the musket, drenched with her own blood!
   Not till the dawn he heard it, and his face grew grey to hear
   How Bess, the landlord’s daughter,
            The landlord’s black-eyed daughter,
   Had watched for her love in the moonlight, and died in the darkness there.

   Back, he spurred like a madman, shrieking a curse to the sky,
   With the white road smoking behind him and his rapier brandished high.
   Blood red were his spurs in the golden noon; wine-red was his velvet coat;
   When they shot him down on the highway,
            Down like a dog on the highway,
   And he lay in his blood on the highway, with a bunch of lace at his throat.

   And still of a winter’s night, they say, when the wind is in the trees,
   When the moon is a ghostly galleon tossed upon cloudy seas,
   When the road is a ribbon of moonlight over the purple moor,
   A highwayman comes riding—
            Riding—riding—
   A highwayman comes riding, up to the old inn-door.

   Over the cobbles he clatters and clangs in the dark inn-yard.
   He taps with his whip on the shutters, but all is locked and barred.
   He whistles a tune to the window, and who should be waiting there
   But the landlord’s black-eyed daughter,
            Bess, the landlord’s daughter,
   Plaiting a dark red love-knot into her long black hair.

   -------------------------------------------------------------------------------

   As you finish reading this poem, a horse appears from around a bend in a road
   and gallops up to you. On the back of the horse is The Highwayman and his wife,
   Bess. In THIS reality, the Ostler never betrayed The Highwayman, and he and the
   innkeeper's daughter Bess eloped. They prove friendly. They dismount from their
   horse and set-up camp near the side of the road and share food and drink with
   you. After spending some hours story-telling and sharing experiences, the three
   of you grow tired and lie down and sleep. When you awake in the morning, The
   Highwayman and Bess are gone, and so are several valuable items which you had
   in your possession. He couldn't help it, you see; it's his nature.
   END_OF_HIGHWAY
} # end sub highway

sub swagman {
   print ((<<'   END_OF_SWAGMAN') =~ s/^   //gmr);

   -------------------------------------------------------------------------------

   Waltzing Matilda
   By Andrew Barton "Banjo" Paterson, CBE

   Oh there once was a swagman camped in the billabong,
   under the shade of a coolibah tree.
   And he sang as he looked at the old billy boiling:
   "Who'll come a waltzing matilda with me?"

   Who'll come a waltzing matilda my darling
   Who'll come a waltzing matilda with me
   Waltzing matilda and leading a water bag
   Who'll come a waltzing matilda with me

   Down came a jumbuck to drink at the billabong;
   up jumped the swagman and grabbed him with glee.
   And he said as he put him away in the tucker bag
   "You'll come a'waltzing matilda with me!"

   Who'll come a waltzing matilda my darling
   Who'll come a waltzing matilda with me
   Waltzing matilda and leading a water bag
   Who'll come a waltzing matilda with me

   Down came the squatter a'riding his thoroughbred.
   Down came policemen, one, two, and three.
   "Whose is the jumbuck you've got in the tucker bag?
   You'll come a'waltzing matilda with we!"

   Who'll come a waltzing matilda my darling
   Who'll come a waltzing matilda with me
   Waltzing matilda and leading a water bag
   Who'll come a waltzing matilda with me

   But the swagman he up and he jumped in the water-hole
   Drowning himself by the coolibah tree
   And his ghost may be heard as it sings by the billabong:
   "Who'll come a'waltzing matilda with me?"

   Who'll come a waltzing matilda my darling
   Who'll come a waltzing matilda with me
   Waltzing matilda and leading a water bag
   Who'll come a waltzing matilda with me

   -------------------------------------------------------------------------------

   As you finish reading this poem, an Australian swagman walks up and introduces
   himself. You can tell that he's not really alive because he's slightly
   transparent, but that doesn't bother you. You and he gather some desert scrub
   and start a campfire. The swagman finds a stream, gathers water, and makes tea.
   You and he eat roasted jumbuck, drink tea, swap stories, and have a good time.
   END_OF_SWAGMAN
} # end sub swagman

sub nazgûl {
   print ((<<'   END_OF_NAZGÛL') =~ s/^   //gmr);

   -------------------------------------------------------------------------------

   Ash nazg durbatulûk
   Ash nazg gimbatul
   Ash nazg thrakatulûk
   Agh burzum-ishi krimpatul

   -------------------------------------------------------------------------------

   As you finish reading this vile poem, the parchment falls from your hands
   onto the dusty ground. Nine all-black figures ride up on nine black horses
   with glowing red eyes. You are about to have the worst day of your life.
   Unfortunately it will also be the LAST day of your life as a human. You are
   about to be stabbed in your heart with a morgul knife and become a wraith.
   END_OF_NAZGÛL
} # end sub nazgûl

sub cthulhu {
   print ((<<'   END_OF_CTHULHU') =~ s/^   //gmr);

   -------------------------------------------------------------------------------

   Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn.

   -------------------------------------------------------------------------------

   As you finish reading this vile poem, the parchment falls from your hands onto
   the ground. The spacetime continuum in front of you shatters and a hideous
   monster erupts from the breech and stands in front of you, gazing into your
   soul with glowing red eyes. You are about to have the worst day of your life.
   Unfortunately it will also be the LAST day of your life as a free, sane human.
   You are about to be enthralled to Cthulhu and become his slave.
   END_OF_CTHULHU
} # end sub cthulhu

__END__
