#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# global-time.pl
# Displays current time at various locations, in any of several formats.
# Written by Robbie Hatley.
#
# Edit history:
# Sun May 03, 2015: Wrote first draft.
# Fri Jul 17, 2015: Made some minor improvements.
# Sat Apr 16, 2016: Converted from ASCII to UTF-8, and now using -CSDA.
# Sun Dec 31, 2017: Wrote help().
# Thu Feb 04, 2021: Changed name of this file to "global-time.pl".
# Mon Feb 15, 2021: Pulled all time-related subs from RH::Util and dropped them in here instead, as they're
#                   highly-experimental and they're ONLY being used here.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Thu Oct 03, 2024: Got rid of Sys::Binmode and common::sense; added "use utf8".
# Tue Mar 11, 2025: -C63. Reduced width from 120 to 110. Increased min ver from "5.32" to "5.36". Got rid of
#                   all prototypes. Added signatures. Changed bracing to C-style. Got rid of all given/when.
#                   Added "Hawaii", "Aleutian", "Arizona", and "Navajo" time zones.
# Thu Apr 24, 2025: Added "use utf8::all". Simplified shebang to "#!/usr/bin/env perl". Corrected error in
#                   regexps for custom zone in which [+-] was mandatory instead of optional as it should have
#                   been. ("--zone=3" should be construed as +3.) Now using "Switch" instead of if/elsif/else.
# Sun Apr 27, 2025: Got rid of "use RH::Util" (not needed).
##############################################################################################################

use v5.36;
use utf8::all;
use Switch;

# Constants:
my @days_per_month = (31,28,31,30,31,30,31,31,30,31,30,31);

# Settings:
$"          = ', ';
my @Opts    = ();
my @Args    = ();
my $Help    = 0;
my $Debug   = 0;
my $Zone    = 'pacific';
my $Style   = '12h';
my $Length  = 'short';

# Subroutine pre-declarations:
sub argv           ; # Process @ARGV and set settings.
sub print_settings ; # Print settings.
sub is_leap_year   ; # Is a given year a leap year?
sub days_in_month  ; # How many days are in a specific month in a specific year?
sub format_time    ; # Return human-readable time and date strings.
sub help           ; # Print help.

{ # begin main
   argv;
   $Debug and print_settings;
   $Help and help and exit(777);
   my  ($time_string, $date_string) = format_time(time, $Zone, $Style, $Length);
   say "$time_string, $date_string";
   exit 0;
} # end main

# Process @ARGV and set settings:
sub argv {
   # Get options and arguments:
   my $end = 0;               # end-of-options flag
   my $s = '[a-zA-Z0-9]';     # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.+-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, +, -)
   for ( @ARGV ) {            # For each element of @ARGV,
      /^--$/ && !$end         # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1            # so if we see that, then set the "end-of-options" flag
      and push @Opts, $_      # and push the "--" to @Opts
      and next;               # and skip to next element of @ARGV.
      !$end                   # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/      # and if we get a valid short option
      ||  /^--(?!-)$d+$/ )    # or a valid long option,
      and push @Opts, $_      # then push item to @Opts
      or  push @Args, $_;     # else push item to @Args.
   }

   # Process options:
   for ( @Opts ) {
      /^-$s*h/ || /^--help$/     and $Help   = 1          ;
      /^-$s*d/ || /^--debug$/    and $Debug  = 1          ;
      /^-$s*w/ || /^--hawaii$/   and $Zone   = 'hawaii'   ;
      /^-$s*i/ || /^--aleutian$/ and $Zone   = 'aleutian' ;
      /^-$s*k/ || /^--alaska$/   and $Zone   = 'alaska'   ;
      /^-$s*p/ || /^--pacific$/  and $Zone   = 'pacific'  ;
      /^-$s*n/ || /^--navajo$/   and $Zone   = 'navajo'   ;
      /^-$s*z/ || /^--arizona$/  and $Zone   = 'arizona'  ;
      /^-$s*m/ || /^--mountain$/ and $Zone   = 'mountain' ;
      /^-$s*c/ || /^--central$/  and $Zone   = 'central'  ;
      /^-$s*e/ || /^--eastern$/  and $Zone   = 'eastern'  ;
      /^-$s*a/ || /^--atlantic$/ and $Zone   = 'atlantic' ;
      /^-$s*u/ || /^--utc$/      and $Zone   = 'utc'      ;
      /^--zone=(.+)$/            and $Zone   = $1         ; # Custom time zone offset, including DST.
      /^-$s*1/ || /^--12h$/      and $Style  = '12h'      ;
      /^-$s*2/ || /^--24h$/      and $Style  = '24h'      ;
      /^-$s*l/ || /^--long$/     and $Length = 'long'     ;
      /^-$s*s/ || /^--short$/    and $Length = 'short'    ;
      /^-$s*t/ || /^--tiny$/     and $Length = 'tiny'     ;
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Print settings:
sub print_settings {
   print STDERR "\@Opts    = (@Opts)\n"
               ."\@Args    = (@Args)\n"
               ."\$Help    = $Help\n"
               ."\$Debug   = $Debug\n"
               ."\$Zone    = $Zone\n"
               ."\$Style   = $Style\n"
               ."\$Length  = $Length\n";
}

# Is a given year a leap year?
sub is_leap_year ($Year) {
   my $Leap = (0 == $Year % 4 && 0 != $Year % 100) || (0 == $Year % 400);
   return $Leap;
} # end is_leap_year

# How many days are in a specific month in a specific year?
sub days_in_month ($month, $year) {
   1 == $month and return ((is_leap_year($year)) ? 29 : 28)
   or return $days_per_month[$month];
} # end sub days_in_month

# Sub "format_time", given an epoch time (seconds since midnight on
# Jan 1, 1970), gives a nicely-formated human-readable time string,
# controlled by 4 inputs:
# 1. $time = seconds since 00:00:00 on Jan 1 1970
#    valid values of are integers 0 through 9223372036854775807.
# 2. $zone = name of time zone.
# 3. $style = "12h" or "24h".
# 4. $length = verbosity of output. Valid values are "tiny", "short",
#    or "long", defaulting to "short".
sub format_time ($time, $zone, $style, $length) {
   my ($gt_second,       $gt_minute,      $gt_hour,
       $gt_day_of_month, $gt_month,       $gt_year,
       $gt_day_of_week,  $gt_day_of_year, $gt_is_dst)
      = gmtime($time);

   my ($lt_second,       $lt_minute,      $lt_hour,
       $lt_day_of_month, $lt_month,       $lt_year,
       $lt_day_of_week,  $lt_day_of_year, $lt_is_dst)
      = localtime($time);

   my ($zt_second,       $zt_minute,      $zt_hour,
       $zt_day_of_month, $zt_month,       $zt_year,
       $zt_day_of_week,  $zt_day_of_year, $zt_is_dst)
      =
      ($gt_second,       $gt_minute,      $gt_hour,
       $gt_day_of_month, $gt_month,       $gt_year,
       $gt_day_of_week,  $gt_day_of_year, $lt_is_dst);

   # ========== SET ACRONYM AND OFFSET FOR TIME ZONE: ========================================================
   my $acro;         # three-letter zone acronym
   my $offset;       # ZoneTime - UtcTime

   # Where in The World are we???
   switch ( $Zone ) {
      case m/hawaii/i {                           # Hawaii   Time Zone (no  DST)
         $acro   =                        'HST' ;
         $offset =                          -10 ;
      }

      case m/aleutian/i {                         # Aleutian Time Zone (yes DST)
         $acro   = $lt_is_dst ?  'HDT' :  'HST' ;
         $offset = $lt_is_dst ?     -9 :    -10 ;
      }

      case m/alaska/i {                           # Alaska   Time Zone (yes DST)
         $acro   = $lt_is_dst ? 'AKDT' : 'AKST' ;
         $offset = $lt_is_dst ?     -8 :     -9 ;
      }

      case m/pacific/i {                          # Pacific  Time Zone
         $acro   = $lt_is_dst ?  'PDT' :  'PST' ;
         $offset = $lt_is_dst ?     -7 :     -8 ;
      }

      case m/arizona/i {                          # Non-Navajo Arizona Time Zone (no DST)
         $acro   =                        'MST' ;
         $offset =                           -7 ;
      }

      case m/navajo/i {                           # Navajo Arizona Time Zone (yes DST)
         $acro   = $lt_is_dst ?  'MDT' :  'MST' ;
         $offset = $lt_is_dst ?     -6 :     -7 ;
      }

      case m/mountain/i {                         # Mountain Time Zone
         $acro   = $lt_is_dst ?  'MDT' :  'MST' ;
         $offset = $lt_is_dst ?     -6 :     -7 ;
      }

      case m/central/i {                          # Central  Time Zone
         $acro   = $lt_is_dst ?  'CDT' :  'CST' ;
         $offset = $lt_is_dst ?     -5 :     -6 ;
      }

      case m/eastern/i {                          # Eastern  Time Zone
         $acro   = $lt_is_dst ?  'EDT' :  'EST' ;
         $offset = $lt_is_dst ?     -4 :     -5 ;
      }

      case m/atlantic/i {                         # Atlantic  Time Zone
         $acro   = $lt_is_dst ?  'ADT' :  'AST' ;
         $offset = $lt_is_dst ?     -3 :     -4 ;
      }

      case m/utc/i {                              # UTC (never uses DST)
         $acro   =                        'UTC' ;
         $offset = 0                            ;
      }

      case m/^[+-]?\d+$/ {                        # Custom time-zone offset, including DST if in-use.
         $acro = 'Z'.$zone                      ;
         $offset = $zone                        ;
      }

      else {                                      # Unknown time zone.
         die "Unknown time zone.\n"             ;
      }
   }
   $Debug and print "After time-zone switch:\n"
                   ."Zone = \"$Zone\", Acro = \"$acro\", Offset = \"$offset\".\n";

   # ======= TIME: ===========================================================================================
   $zt_hour = $gt_hour + $offset;
   $Debug and say "\$zt_hour, after adding offset, = $zt_hour";
   if ($zt_hour < 0) {             # if this zone is previous day relative to London
      $zt_hour += 24;              #    add 24 to hour
      --$zt_day_of_week;           #    subtract 1 from day-of-week
      $Debug and say "Diminished \$zt_day_of_week = $zt_day_of_week";
      if ($zt_day_of_week == -1) { #    if DOW == -1,
         $zt_day_of_week = 6;      #       set DOW to 6.
      }
      --$zt_day_of_month;          #    subtract 1 from day-of-month
      if ($zt_day_of_month == 0) { #    if DOM == 0,
         --$zt_month;              #       subtract 1 from month
         if ($zt_month == -1) {    #       if month is -1,
            $zt_month = 11;        #          set month to 11
            --$zt_year;            #          and subtract 1 from year
         }
         $zt_day_of_month = days_in_month($zt_month,$zt_year);
      }
   }

   my $hour;                # hour     string
   my $minu = $zt_minute;   # minutes  string
   my $seco = $zt_second;   # seconds  string
   my $meri;                # meridian string
   my $time_string_format;  # format   string for printf

   if ($style =~ m/24h/i) {                          # Use 24-hour time if user specifically requests it;
      $hour = $zt_hour;
      $meri = '';
      $time_string_format = "%02d:%02d:%02d%s%s";
   }
   else {                                            # otherwise, use 12-hour (AM/PM) time.
      $hour = ($zt_hour + 11) % 12 + 1;
      $meri = ($zt_hour > 11 ? 'P' : 'A').'M';
      $time_string_format = "%d:%02d:%02d %s %s";
   }

   my $time_string = sprintf("$time_string_format", $hour, $minu, $seco, $meri, $acro);

   # ======= DATE: ===========================================================================================
   my $year = 1900 + $zt_year;
   my $dom = $zt_day_of_month;
   my $date_string;
   if ($length =~ m/tiny/i) {
      my $month = $zt_month + 1;
      $date_string = sprintf("%-4d-%02d-%02d", $year, $month, $dom);
   }
   elsif ($length =~ m/long/i) {
      my @months   = qw( January February March     April     May      June
                         July    August   September October   November December );
      my $month = $months[$zt_month];
      my @weekdays = qw( Sunday Monday Tuesday Wednesday Thursday Friday Saturday );
      my $dow = $weekdays[$zt_day_of_week];
      $date_string = sprintf("%s %s %d, %d", $dow, $month, $dom, $year);
   }
   else { # default to 'short', a happy medium between 'micro' and 'long'
      my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
      my $month = $months[$zt_month];
      my @weekdays = qw( Sun Mon Tue Wed Thu Fri Sat );
      my $dow = $weekdays[$zt_day_of_week];
      $date_string = sprintf("%s %s %02d, %d", $dow, $month, $dom, $year);
   }

   # ========== RETURN RESULT: ==========
   return ($time_string, $date_string);
} # end sub format_time

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "global-time.pl", Robbie Hatley's nifty time & date program.
   This program prints the current time and date at any of various locations,
   nicely-formatted as a human-readable string in any of several formats,
   controlled by the following options:

   Option:                  Meaning:
   -h or --help             Print this help and exit.
   -d or --debug            Print debugging info.
   -w or --hawaii           Hawaii   (never uses DST)
   -i or --aleutian         Aleutian
   -k or --alaska           Alaska
   -p or --pacific          Pacific
   -n or --navajo           Navajo   (uses mountain time and DST)
   -z or --arizona          Arizona  (uses mountain time but NO DST)
   -m or --mountain         Mountain
   -c or --central          Central
   -e or --eastern          Eastern
   -a or --atlantic         Atlantic
   -u or --utc              UTC      (never uses DST)
   --zone=[+|-]##           Set time zone to custom numeric offset.
                            (eg, "--zone=-10 would be Hawaii time)
                            WARNING: custom offset must include DST, if in-use.
                            EG: Anchorage in June would be -8, not -9.
   -1 or --12h              Style  = '12h'
   -2 or --24h              Style  = '24h'
   -l or --long             Length = 'long'
   -s or --short            Length = 'short'
   -t or --tiny             Length = 'tiny'

   Any combination of these options may be used in a command line.
   Use a "--" option to indicate that all further items are arguments.
   Multiple single-letter options may be piled after a single hyphen.
   If two piled-together single-letter options contradict, the option
   appearing lowest on the options chart above will prevail.
   If two separate (not piled-together) options contradict, the right
   overrides the left.

   Default Location is "pacific"
   Default Style    is "12h"
   Default Length   is "short"

   Known bugs:
   1. Only USA's time zones can be requested by name. (But ANY time zone
      can be requested numerically, if you include DST if in-use.)
   2. Happily accepts nonsensical offsets (such as Z+87) and prints equally
      nonsensical results.
   3. Uses Perl's "localtime" function to determine if DST is currently
      in-effect. This will fail if your computer's "locale" settings
      indicate that your location doesn't use DST, or uses non-standard
      DST. In those cases, USA's main time zones (Pacific, Mountain,
      Central, Eastern) may show times that are off by 1 hour.

   Maybe some day if I get bored, I'll put all of Earth's time zones in here
   and fix all of the bugs and problems. But today is not that day

   Cheers,
   Robbie Hatley,
   Programmer.
   END_OF_HELP
   return 1;
} # end sub help
