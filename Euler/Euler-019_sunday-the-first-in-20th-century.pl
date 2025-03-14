#!/usr/bin/perl

# This is an 79-character-wide ASCII-encoded Perl source-code text file.
# =======|=========|=========|=========|=========|=========|=========|=========

###############################################################################
# /rhe/scripts/util/Euler-0019_sunday-the-first-in-20th-century.perl          #
# Determines how many Sundays fell on the first of a month during             #
# The 20th Century.                                                           #
# Author: Robbie Hatley                                                       #
# Edit history:                                                               #
#    Wed Dec 24, 2016 - Wrote it.                                             #
###############################################################################

use v5.022;
use strict;
use warnings;
no  warnings 'experimental::smartmatch';


# ======= VARIABLES: ==========================================================

my @days_in_month = (31,28,31,30,31,30,31,31,30,31,30,31);

# ================ SUBROUTINE PRE-DECLARATIONS ================================

sub days_per_year  ($);   # How many days in given whole year?
sub days_per_month ($$);  # How many days in given whole month?
sub is_leap_year   ($);   # Is given year a leap year?
sub elapsed_time   ($$$); # Days elapsed [Dec_31_1899 , given_date).
sub day_of_week    ($$$); # What day of week is current date?

# ================ MAIN BODY OF PROGRAM =======================================

# main
{
   my $Sundays = 0;
   for my $Year ( 1901 .. 2000 )
   {
      for my $Month ( 1 .. 12 )
      {
         # If 1st of month is Sunday, increment $Sundays:
         if ( 0 == ( elapsed_time($Year, $Month, 1) % 7 ) ) {++$Sundays;}
      }
   }

   say $Sundays;

   # We be done, so scram:
   exit 0;
} # end main

# ================ SUBROUTINE DEFINITIONS =====================================

sub days_per_year ($)
{
   my $Year = shift;
   if ($Year < 1899)
   {
      die "Error in days_per_year: cannot calculate elapsed time for\n"
        . "dates before Dec 31, 1899.\n";
   }
   elsif ($Year == 1899)
   {
      return 1;
   }
   else # $Year > 1899
   {
      my $DaysPerYear = 365;
      if (is_leap_year($Year)) {++$DaysPerYear;}
      return $DaysPerYear;
   }
}

sub days_per_month ($$) {
   my $Year  = shift;
   my $Month = shift;
   if ($Month < 1 || $Month > 12) {
      die "Illegal month.\n";
   }
   elsif (2 == $Month) {
      return (is_leap_year($Year) ? 29 : 28);
   }
   else {
      return $days_in_month[$Month-1];
   }
}

sub is_leap_year ($)
{
   my $Year = shift;

   if    ( 0 == $Year%4 && 0 != $Year%100 ) {return 1;}
   elsif ( 0 == $Year%400 )                 {return 1;}
   else                                     {return 0;}
}

# Calculate days elapsed from Dec 31, 1899 up to but NOT including
# any given date:
sub elapsed_time ($$$)
{
   my $Year  = shift;
   my $Month = shift;
   my $Day   = shift;

   my $Elapsed = 0;

   # ==========================================================================
   # FIRST, ADD IN DAYS FROM WHOLE YEARS WHICH HAVE ELAPSED SINCE DEC 31, 1899.

   # (But that depends very much on what $Year is relative to 1899,
   # because I'm choosing Sun Dec 31 1899 as "baseline", because it's the
   # first day of the first week of 1900.)

   # If $Year is before 1899, that's an error; we can't calculate
   # time that far back:
   if ($Year < 1899)
   {
      die "Error in elapsed_time: cannot calculate elapsed time for\n"
        . "dates before Dec 31, 1899.\n";
   }

   # If $Year is 1899, that's *also* an error, unless the  date
   # is Dec 31, 1899, in which case exactly 0 days have elapsed so return 0:
   elsif ($Year == 1899)
   {
      if ($Month == 12 && $Day == 31)
      {
         return 0; # 0 days have elapsed from Dec 31 1899 to Dec 31 1899.
      }
      else
      {
         die "Error in elapsed_time: cannot calculate elapsed time for\n"
           . "dates before Dec 31, 1899.\n";
      }
   }

   # Otherwise, $Year > 1899, so add-in all days from any whole years
   # which have elapsed, from 1899 up to (but NOT including)  year.
   # Bear in mind that days_per_year will return 1 for the year 1899,
   # 365 or 366 for years after 1899, or will die if fed a year prior to 1899.
   else
   {
      # Add-in days from
      foreach my $PassingYear( 1899 .. $Year - 1 )
      {
         $Elapsed += days_per_year($PassingYear);
      }
   }

   # ==========================================================================
   # NEXT, ADD IN DAYS FROM WHOLE MONTHS WHICH HAVE ELAPSED IN  YEAR:

   # Add in the days contained by whole months which have elapsed from January
   # through the month before  month (if any):
   if ($Month > 1)
   {
      foreach my $PassingMonth ( 1 .. $Month - 1 )
      {
         $Elapsed += days_per_month($Year, $PassingMonth);
      }
   }

   # ==========================================================================
   # LASTLY, ADD IN DAYS WHICH HAVE ELAPSED IN  MONTH:

   # Add in the days which have elapsed so far in this month, but do NOT count
   #  day as having "elapsed", because we are counting Mon Dec 31, 1899
   # (the other end of the fence run) as being "elapsed", so if we also count
   # *this* end, we'll have a fencepost error, and Jan 2, 1900 will come out as
   # being 2 days after Jan 1, 1900, and all later days would also be off by 1:
   $Elapsed += ($Day - 1);

   # Return elapsed time:
   return $Elapsed;
}
