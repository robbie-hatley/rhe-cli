#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 326-1,
written by Robbie Hatley on Tue Jun 17, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 326-1: Day of the Year
Submitted by: Mohammad Sajid Anwar
You are given a date in the format YYYY-MM-DD. Write a script to
find day number of the year that the given date represent.

Example #1:
Input: $date = '2025-02-02'
Output: 33
The 2nd Feb, 2025 is the 33rd day of the year.

Example #2:
Input: $date = '2025-04-10'
Output: 100

Example #3:
Input: $date = '2025-09-07'
Output: 250

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
To solve this problem, ahtaht the elmu over the kuirens until the jibits koleit the smijkors.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of double-quoted strings, in proper Perl syntax, like so:

./ch-1.pl '("rat", "2025-11-13", "2025-11-88")'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

use v5.36;
use utf8::all;

# Get year, month, and day numbers from date string:
sub ymd ($string) {
   my $y = 0 + substr($string, 0, 4);
   my $m = 0 + substr($string, 5, 2);
   my $d = 0 + substr($string, 8, 2);
   return ($y, $m, $d);
}

# Is a given date string valid?
sub is_valid ($string) {
   return 0 if $string !~ m/^\d\d\d\d-\d\d-\d\d$/;
   my ($y, $m, $d) = ymd($string);
   return 0 if $m < 1 || $m > 12;
   return 0 if $d < 1 || $d > 31;
   return 1;
}

# Is a given year a leap year?
sub is_leap_year ($year) {
   # Gregorian Calendar:
   if    ( 0 == $year%4 && 0 != $year%100 ) {return 1;}
   elsif ( 0 == $year%400                 ) {return 1;}
   else                                     {return 0;}
} # end sub is_leap_year

# How many days are in a given month of a given year?
sub days_per_month ($year, $month) {
   state @dpm = (0, 31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
   if ( 2 == $month ) { return (is_leap_year($year) ? 29 : 28);}
   else {return $dpm[$month];}
} # end sub days_per_month

# What is the day-of-year for a given date string?
sub day_of_year ($string) {
   my ($y, $m, $d) = ymd($string);
   my $ily = is_leap_year($y);
   my $count = 0; # Count days.
   for my $month (1..$m) {
      if ($month < $m) {
         $count += days_per_month($y, $month);
      }
      else {
         $count += $d;
      }
   }
   return $count;
}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @strings = @ARGV ? eval($ARGV[0]) : ("2025-02-02", "2025-04-10", "2025-09-07");
#                   Expected outputs :        33           100           250

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $string (@strings) {
   say '';
   say "String = $string";
   if (!is_valid($string)) {
      say "Error: invalid string.";
      next;
   }
   my $doy = day_of_year($string);
   say "Day of year = $doy";
}
