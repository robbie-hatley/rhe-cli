#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 348-1,
written by Robbie Hatley on Mon Nov 17, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 348-1: String Alike
Submitted by: Mohammad Sajid Anwar
Write a script to find out whether a given string can be split
into two halves of equal lengths, each with the same non-zero
number of vowels.

Example #1:
Input:  "textbook"
Output: false
1st half: "text" (1 vowel)
2nd half: "book" (2 vowels)

Example #2:
Input:  "book"
Output: true
1st half: "bo" (1 vowel)
2nd half: "ok" (1 vowel)

Example #3:
Input:  "AbCdEfGh"
Output: true
1st half: "AbCd" (1 vowel)
2nd half: "EfGh" (1 vowel)

Example #4:
Input:  "rhythmmyth"
Output: false
1st half: "rhyth" (0 vowel)
2nd half: "mmyth" (0 vowel)

Example #5:
Input:  "UmpireeAudio"
Output: false
1st half: "Umpire" (3 vowels)
2nd half: "eAudio" (5 vowels)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
Firstly, if the string has odd length, return 'false'. Otherwise, just split the string in-half and count
vowels in the halves, then use this logic:
if ( $v1<1 || $v2<1 || $v1 != $v2 ) { return 'false' }
else                                { return 'true'  }
That's assuming that "vowel" means "one of [aeiouAEIOU]". Should I bother stripping any diacritical marks?
Probably, but not in the first draft.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of double-quoted strings, in proper Perl syntax, like so:

./ch-1.pl '("cucumber", "potato", "RUTABEGA", "onion")'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use utf8::all;

   # Can we split a given string into two equal-length
   # halves with equal non-zero numbers of vowels?
   sub can_split ( $s ) {
      my $l = length($s);
      if ( 0 != $l % 2 ) { return 'false' }
      my $s1 = substr $s,   0 , $l/2;
      my $s2 = substr $s, $l/2, $l/2;
      my $v1 = length($s1 =~ s/[^aeiou]//igr);
      my $v2 = length($s2 =~ s/[^aeiou]//igr);
      return 'false' if $v1<1 || $v2<1 || $v1 != $v2;
      return 'true'}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @strings = @ARGV ? eval($ARGV[0]) :
(
   "textbook",     # Expected output: false
   "book",         # Expected output: true
   "AbCdEfGh",     # Expected output: true
   "rhythmmyth",   # Expected output: false
   "UmpireeAudio", # Expected output: false
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $s (@strings) {
   say '';
   say "String = \"$s\"";
   my $cs = can_split($s);
   say "Can split into equal length halves with equal, non-zero numbers of vowels? $cs"
}
