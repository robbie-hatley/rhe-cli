#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 328-2,
written by Robbie Hatley on Thu Jul 17, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 328-2: Good String
Submitted by: Mohammad Sajid Anwar
You are given a string made up of lower and upper case English
letters only. Write a script to return the good string of the
given string. A string is called good string if it doesn’t have
two adjacent same characters, one in upper case and other is
lower case. To be explicit, you can only remove a pair if they
are same characters, one in lower case and other in upper case;
order is not important.

Example 1
Input: $str = "WeEeekly"
Output: "Weekly"
We can remove either, "eE" or "Ee" to make it good.

Example 2
Input: $str = "abBAdD"
Output: ""
We remove "bB" first: "aAdD"
Then we remove "aA": "dD"
Finally remove "dD".

Example 3
Input: $str = "abc"
Output: "abc"

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
To solve this problem, I'll use a 3-part index loop to find-and-remove all "bad pairs" of characters, with
double index back-tracking after every deletion to prevent skipping any character pairs. (Single backtracking
won't work, because removing a pair of characters may change the relationship between previous and next
characters.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of double-quoted strings, in proper Perl syntax, like so:

./ch-2.pl '("bat", "beEeet", "cattT")'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use utf8::all;

   # Remove bad pairs to make good string:
   sub good ($s) {
      for ( my $i = 0 ; $i <= length($s)-2 ; ++$i ) {
         my $x = substr($s, $i + 0, 1);
         my $y = substr($s, $i + 1, 1);
         if (  $x eq lc($y) && $y eq uc($x)
            || $x eq uc($y) && $y eq lc($x) ) {
            substr($s, $i, 2, '');
            # Backtrack index by 2 to avoid skipping.
            # But if resulting index is less than -1,
            # then set it to -1:
            $i -= 2; $i = -1 if $i < -1}}
      return $s}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @strings = @ARGV ? eval($ARGV[0]) : ("WeEeekly", "abBAdD", "abc");
#                   Expected outputs :  "Weekly"    ""        "abc"

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $string (@strings) {
   say '';
   say "Original string = $string";
   my $good = good($string);
   say "Good     string = $good";
}
