#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

--------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
ch-2.pl
Solutions in Perl for The Weekly Challenge 219-2.
Written by Robbie Hatley on Sat May 13, 2023.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 2: Travel Expenditure
Submitted by: Mohammad S Anwar

You are given two list, @costs and @days.

The list @costs contains the cost of three different types of travel cards you can buy.

For example @costs = (5, 30, 90)

Index 0 element represent the cost of  1 day  travel card.
Index 1 element represent the cost of  7 days travel card.
Index 2 element represent the cost of 30 days travel card.

The list @days contains the day number you want to travel in the year.

For example: @days = (1, 3, 4, 5, 6)

The above example means you want to travel on day 1, day 3, day 4, day 5 and day 6 of the year.

Write a script to find the minimum travel cost.
Example 1:

Input: @costs = (2, 7, 25)
       @days  = (1, 5, 6, 7, 9, 15)
Output: 11

On day 1, we buy a one day pass for 2 which would cover the day 1.
On day 5, we buy seven days pass for 7 which would cover days 5 - 9.
On day 15, we buy a one day pass for 2 which would cover the day 15.

So the total cost is 2 + 7 + 2 => 11.

Example 2:

Input: @costs = (2, 7, 25)
       @days  = (1, 2, 3, 5, 7, 10, 11, 12, 14, 20, 30, 31)
Output: 20

On day 1, we buy a seven days pass for 7 which would cover days 1 - 7.
On day 10, we buy a seven days pass for 7 which would cover days 10 - 14.
On day 20, we buy a one day pass for 2 which would cover day 20.
On day 30, we buy a one day pass for 2 which would cover day 30.
On day 31, we buy a one day pass for 2 which would cover day 31.

So the total cost is 7 + 7 + 2 + 2 + 2 => 20.

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
Budget calculations. Grrr. Just looking at that gives me a headache. I don't think I'm going to have the
time, energy, concentration, or patience to do challenge #2 this week.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of arrays in proper Perl syntax, like so:
./ch-1.pl '([[13,0,96],[-8,3,11],[2,6,4]], [[-83,-42,-57],[-99,478,952],[113,127,121]])'

Output is to STDOUT and will be each input array, followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRELIMINARIES:
use v5.36;
use strict;
use warnings;
use utf8;
use Time::HiRes 'time';
use List::Util  'max';
use Math::Combinatorics;
$"=', ';

# ------------------------------------------------------------------------------------------------------------
# SUBROUTINES:
sub is_in_list ($item, $list) {
   for (@$list) {$item eq $_ and return 1;}
   return 0;
}

# ------------------------------------------------------------------------------------------------------------
# DEFAULT INPUTS:
my @arrays =
(
   [
      [40,3,17],
      [19,7,438],
      [5,191,18],
   ],
   [
      [7,3,2],
      [8,9,10],
      [18,6,34],
   ],
   [
      [9,5,33],
      [1,2,1],
      [8,17,64],
   ],
);

# ------------------------------------------------------------------------------------------------------------
# NON-DEFAULT INPUTS:
if (@ARGV) {@arrays = eval($ARGV[0]);}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
{ # begin main
   my $t0 = time;
   for my $mref (@arrays) {
      my $max = $mref->[0]->[0];
      for my $rref (@$mref) {
         for my $element (@$rref) {
            $element > $max and $max = $element;
         }
      }
      say '';
      say 'matrix:';
      for my $rref (@$mref) {
         say "[@$rref],";
      }
      say "max = $max";
   }
   my $µs = 1000000 * (time - $t0);
   printf("\nExecution time was %.3fµs.\n", $µs);
   exit 0;
} # end main
