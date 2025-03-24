#!/usr/bin/env -S perl -C63

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 314-1,
written by Robbie Hatley on Mon Mar 24, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 314-1: Equal Strings
Submitted by: Mohammad Sajid Anwar
You are given three strings. You are allowed to remove the
rightmost character of a string to make all equals. Write a
script to return the number of operations to make it equal
otherwise -1.

Example #1:
Input: $s1 = "abc", $s2 = "abb", $s3 = "ab"
Output: 2
Operation 1: Delete "c" from the string "abc"
Operation 2: Delete "b" from the string "abb"

Example #2:
Input: $s1 = "ayz", $s2 = "cyz", $s3 = "xyz"
Output: -1

Example #3:
Input: $s1 = "yza", $s2 = "yzb", $s3 = "yzc"
Output: 3

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
The first thing I note is that "-1" will have to be returned if-and-only-if the 3 input strings do NOT all
start with the same first character. (The examples rule-out the idea that 3 empty strings should be considered
"equal".) With that in-mind, I see two main ways to attack this:

1. Nibble from the right, chopping-off substrings until the 3 strings are equal, and count operations.
2. Count from the left, counting triplets of equal characters. Substract number of equal chars from total.

Either will the the same answer. I'll go with option 2, because it gives an easy way to determine when -1
should be returned: precisely when the number of equal characters (counted in triplets from the left) is 0.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of double-quoted strings, apostrophes escaped as '"'"', in proper Perl syntax:
./ch-1.pl '(["She shaved?", "She ate 7 hot dogs."],["She didn'"'"'t take baths.", "She sat."])'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use utf8;
   use List::Util qw( min max sum0);

   # How many characters need to be excised from the right
   # ends of a triplet of strings to make them all equal?
   sub equal_strings {
      my ($x,$y,$z) = @_ ;
      my ($l,$m,$n) = (length($x),length($y),length($z));
      my $min_len =  min($l,$m,$n);
      my $max_len =  max($l,$m,$n);
      my $sum_len = sum0($l,$m,$n);
      my $index = 0;
      for ( ; $index <  $max_len ; ++$index ) {
         last unless $index < $min_len
            && substr($x,$index,1) eq substr($y,$index,1)
            && substr($y,$index,1) eq substr($z,$index,1)
            && substr($z,$index,1) eq substr($x,$index,1);
      }
      $index and return ($sum_len - (3 * $index)) or return -1;
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) : (["abc", "abb", "ab"], ["ayz", "cyz", "xyz"], ["yza", "yzb", "yzc"]);
#                  Expected outputs :            2                    -1                      3

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   my ($x,$y,$z) = @$aref;
   my $ops = equal_strings($x,$y,$z);
   print "\n";
   print "First  string = $x\n";
   print "Second string = $y\n";
   print "Third  string = $z\n";
   print "$ops operations were required to equalize strings.\n";
}
