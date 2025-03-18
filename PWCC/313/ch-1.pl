#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 313-1,
written by Robbie Hatley on Tue Mar 18, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 313-1: Broken Keys
Submitted by: Mohammad Sajid Anwar
You have a broken keyboard which sometimes type a character more
than once. You are given a string and actual typed string. Write
a script to find out if the actual typed string is meant for the
given string.

Example #1:
Input: $name = "perl", $typed = "perrrl"
Output: true
Here "r" is pressed 3 times instead of 1 time.

Example #2:
Input: $name = "raku", $typed = "rrakuuuu"
Output: true

Example #3:
Input: $name = "python", $typed = "perl"
Output: false

Example #4:
Input: $name = "coffeescript", $typed = "cofffeescccript"
Output: true

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
I'll approach this by making "signature" arrays for "$name" and "$typed" consisting of [letter, number] pairs
indicating each contiguous group of identical characters within each string. For "$typed" to match "$name",
the two arrays must be of equal length, with the same sequence of characters, with the multiplicity number
of "$typed" being greater-than-or-equal-to the multiplicity number of "$name".

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of two double-quoted strings, in proper Perl syntax, like so:
./ch-1.pl '(["Robbie", "Roobbbbbiiiee"], ["Hatley", "Hately"])'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.38;
   use utf8;

   # Is a second string a "broken keys" version of a first string?
   sub broken_keys ($x, $y) {
      my @xsig; # Signatures for first  string.
      my @ysig; # Signatures for second string.
      my $previdx;
      $previdx = 0;
      for my $idx (1..length($x)) {
         if ( $idx == length($x) || substr($x, $idx, 1) ne substr($x, $idx-1, 1) ) {
            push @xsig, [substr($x, $previdx, 1), $idx-$previdx];
            $previdx = $idx;
         }
      }
      $previdx = 0;
      for my $idx (1..length($y)) {
         if ( $idx == length($y) || substr($y, $idx, 1) ne substr($y, $idx-1, 1) ) {
            push @ysig, [substr($y, $previdx, 1), $idx-$previdx];
            $previdx = $idx;
         }
      }
      if ( scalar(@xsig) != scalar(@ysig) ) {return 'false';}
      for my $idx (0..$#xsig) {
         if ( $xsig[$idx]->[0] ne $ysig[$idx]->[0] ) {return 'false';}
         if ( $xsig[$idx]->[1]  > $ysig[$idx]->[1] ) {return 'false';}
      }
      return 'true';
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   ["perl",         "perrrl"          ], # Expected output: true
   ["raku",         "rrakuuuu"        ], # Expected output: true
   ["python",       "perl"            ], # Expected output: false
   ["coffeescript", "cofffeescccript" ], # Expected output: true
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   my $name   = $aref->[0];
   my $typed  = $aref->[1];
   my $broken = broken_keys($name, $typed);
   say "Original name: $name";
   say "Name as typed: $typed";
   say "Due to broken keys? $broken";
}
