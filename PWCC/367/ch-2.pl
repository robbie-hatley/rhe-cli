#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge ###-2,
written by Robbie Hatley on Tue Mar 31, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 367-2: Conflict Events
Submitted by: Mohammad Sajid Anwar
You are given two events start and end time. Write a script to
find out if there is a conflict between the two events.
A conflict happens when two events have some non-empty
intersection.

Example 1
Input: @event1 = ("10:00", "12:00")
       @event2 = ("11:00", "13:00")
Output: true
Both events overlap from "11:00" to "12:00".

Example 2
Input: @event1 = ("09:00", "10:30")
       @event2 = ("10:30", "12:00")
Output: false
Event1 ends exactly at 10:30 when Event2 starts.
Since the problem defines intersection as non-empty,
exact boundaries touching is not a conflict.

Example 3
Input: @event1 = ("14:00", "15:30")
       @event2 = ("14:30", "16:00")
Output: true
Both events overlap from 14:30 to 15:30.

Example 4
Input: @event1 = ("08:00", "09:00")
       @event2 = ("09:01", "10:00")
Output: false
There is a 1-minute gap from "09:00" to "09:01".

Example 5

Input: @event1 = ("23:30", "00:30")
       @event2 = ("00:00", "01:00")
Output: true
They overlap from "00:00" to "00:30".

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
Given Event E1 as a reference, the outcome will depend on the beginning and end of event E2.
If E2beg is before E1beg, conflict iff E2end is > E1beg.
If E2beg is during E1, conflit.
If E2beg is after  E1, no conflict.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of double-quoted strings, in proper Perl syntax, like so:

./ch-2.pl '(["rat", "bat", "cat"],["pig", "cow", "horse"])'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.42;
   use utf8::all;

   # Aggregate the belchers under the resinous swamps:
   sub events_conflict ( $pair_ref ) {
      my $E1 = $pair_ref->[0];
      my $E1_beg_str = $E1->[0];
      my $E1_end_str = $E1->[1];
      my $E1_beg = 60*substr($E1_beg_str, 0, 2) + substr($E1_beg_str, 3, 2);
      my $E1_end = 60*substr($E1_end_str, 0, 2) + substr($E1_end_str, 3, 2);

      my $E2 = $pair_ref->[1];
      my $E2_beg_str = $E2->[0];
      my $E2_end_str = $E2->[1];
      my $E2_beg = 60*substr($E2_beg_str, 0, 2) + substr($E2_beg_str, 3, 2);
      my $E2_end = 60*substr($E2_end_str, 0, 2) + substr($E2_end_str, 3, 2);

      my $aflag   = '';
      my $ret_val = '';
      if ($E2_beg > $E2_end) {$E2_end += 1440}
      # If E1's clock rolls-over at midnight, assume E2's times refer to
      # the next day, and possibily spill into the next day after THAT as well;
      # however, this is ambiguous, so also set the ambiguity flag:
      if ($E1_beg > $E1_end) {
         $E1_end += 1440;
         $E2_beg += 1440;
         $E2_end += 1440;
         $aflag = ' (Ambiguous. Assumes E2\'s times refer to the next day.)';
      }

      if ($E2_beg < $E1_beg) {
         if ($E2_end <= $E1_beg) {
            $ret_val = 'false';
         }
         else {
            $ret_val = 'true';
         }
      }
      elsif ($E2_beg >= $E1_beg && $E2_beg < $E1_end) {
         $ret_val = 'true';
      }
      else {
         $ret_val = 'false';
      }
      $ret_val .= $aflag;
      return $ret_val;
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   [
      ["10:00", "12:00"],
      ["11:00", "13:00"],
   ],                     # true

   [
      ["09:00", "10:30"],
      ["10:30", "12:00"],
   ],                     # false

   [
      ["14:00", "15:30"],
      ["14:30", "16:00"],
   ],                     # true

   [
      ["08:00", "09:00"],
      ["09:01", "10:00"],
   ],                     # false

   [
      ["23:30", "00:30"],
      ["00:00", "01:00"],
   ],                     # true or false (ambiguous)
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   say events_conflict $aref;
}
