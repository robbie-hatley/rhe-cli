#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 329-2,
written by Robbie Hatley on Thu Jul 17, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 329-2: Nice String
Submitted by: Mohammad Sajid Anwar
You are given a string made up of lower and upper case English
letters only. Write a script to return the longest substring of
the give string which is nice. A string is nice if, for every
letter of the alphabet that the string contains, it appears both
in uppercase and lowercase.

Example #1:
Input: $str = "YaaAho"
Output: "aaA"

Example #2:
Input: $str = "cC"
Output: "cC"

Example #3:
Input: $str = "A"
Output: ""
No nice string found.

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
I used a structured approach. The first thing I needed was to toggle the case of a character, so I made a "tc"
subroutine to do that. Next, I needed a way to determine whether a string is "nice" (as per the problem
description), so I made a "is_nice" subroutine to do that (by using "none" from CPAN module "List::Util to
determine which characters in a string have no opposite-case analogs in the string). And finally, I wrote a
subroutine called "max_nice" which determines the first max-length "nice" substring of the original string.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of double-quoted strings, in proper Perl syntax, like so:

./ch-2.pl '("raAt", "bAatT", "aAxtT", "cCat", "pig", "coWw", "horse")'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use utf8::all;
   use List::Util 'none';

   # Toggle the case of a character:
   sub tc ($x) {
      if ( $x eq uc $x ) {return lc $x}
      else               {return uc $x}}

   # Is a string "nice"?
   sub is_nice ($x) {
      my @chars = split //, $x;
      foreach my $char (@chars) {
         if (none {$_ eq tc $char} @chars) {
            return 0}}
      return 1}

   # What is the first max-length "nice"
   # substring of a string?
   sub max_nice ($x) {
      my $n = length($x);
      my $max_siz = 0;
      my $max_str = '';
      foreach my $start (0..$n-1) {
         foreach my $size (1..$n-$start) {
            my $ss = substr($x, $start, $size);
            if (is_nice($ss)) {
               if (length($ss) > $max_siz) {
                  $max_siz = length($ss);
                  $max_str = $ss}}}}
      return $max_str}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @strings = @ARGV ? eval($ARGV[0]) : ("YaaAho", "cC", "A");
#                   Expected outputs :   "aaA"    "cC   ""

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $string (@strings) {
   say '';
   say "String   = \"$string\"";
   my $mn = max_nice($string);
   say "Max Nice = \"$mn\"";
}
