#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

--------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
Solutions in Perl for The Weekly Challenge 184-2.
Written by Robbie Hatley on Tue Nov 07, 2023.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:

Task 2: Split Array
Submitted by: Mohammad S Anwar
You are given list of strings containing 0-9 and a-z separated by
space only. Write a script to split the data into two arrays, one
for integers and one for alphabets only.

Example 1
Input: @list = ( 'a 1 2 b 0', '3 c 4 d')
Output: [[1,2,0], [3,4]] and [['a','b'], ['c','d']]

Example 2
Input: @list = ( '1 2', 'p q r', 's 3', '4 5 t')
Output: [[1,2], [3], [4,5]] and [['p','q','r'], ['s'], ['t']]

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
I don't like that the problem description indicates that I should elide empty arrays, so I'm not going to do
that. Also, what's up with all the spaces? I'll write a script that's non-white-space-dependent, by splitting
the strings on // instead of / / then just ignoring the spaces in the resulting arrays and cherry-picking
the 0-9 and a-z characters only. Thus my input can be any array of any strings (including empty strings or NO
strings) and yet the output will be the same for the given examples (with the exception that the empty output
arrays won't be elided for Example 2).

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
double-quoted array of arrays of single-quoted strings, apostrophes escaped, in proper Perl syntax, like so:
./ch-2.pl "(['375/5=75', 'She ran home.', 'I ate 375 hot dogs.'],['She sat.', 'I didn\'t sit.'])"

Output is to STDOUT and will be each input array followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS AND MODULES USED:

use v5.38;
use strict;
use warnings;
use utf8;
use warnings FATAL => 'utf8';
use Time::HiRes 'time';

# ------------------------------------------------------------------------------------------------------------
# START TIMER:
our $t0;
BEGIN {$t0 = time}

# ------------------------------------------------------------------------------------------------------------
# SUBROUTINES:

# Format an array of strings as ("str1", "str2", "str3") :
sub arrstr ($aref) {
   return '(' . join(', ', map {"\"$_\""} @$aref) . ')';
}

# Format an array of arrays of strings as ([str1, str2], [str3, str4]) :
sub arrarrstr ($aref) {
   return '(' . join(', ', map {'['.join(', ', @$_).']'} @$aref) . ')';
}

# For any array of strings, return an array of two arrays of arrays,
# where the first  array of arrays contains the digits  [0-9] of the strings,
# and   the second array of arrays contains the letters [a-z] of the strings:
sub numslets ($aref) {
   my @numslets = ([],[]);
   for my $string (@$aref) {
      my @nums;
      my @lets;
      for (split //, $string) {
         /[0-9]/ and push @nums, $_;
         /[a-z]/ and push @lets, $_;
      }
      push @{$numslets[0]}, [@nums];
      push @{$numslets[1]}, [@lets];
   }
   return @numslets;
}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:

# Inputs:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   # Example 1 Input:
   ['a 1 2 b 0', '3 c 4 d'],
   # Expected Outputs:
   # Numbers: ([1, 2, 0], [3, 4])
   # Letters: ([a, b], [c, d])

   # Example 2 Input:
   ['1 2', 'p q r', 's 3', '4 5 t'],
   # Expected Outputs:
   # Numbers: ([1,2], [], [3], [4,5])
   # Letters: ([], [p, q, r], [s], [t])
);

# Main loop:
for my $aref (@arrays) {
   say '';
   my @numslets = numslets($aref);
   say 'Original Array  = ', arrstr    ( $aref        );
   say 'Digit    Arrays = ', arrarrstr ( $numslets[0] );
   say 'Letter   Arrays = ', arrarrstr ( $numslets[1] );
}
exit;

# ------------------------------------------------------------------------------------------------------------
# DETERMINE AND PRINT EXECUTION TIME:
END {my $µs = 1000000 * (time - $t0);printf("\nExecution time was %.0fµs.\n", $µs)}
__END__
