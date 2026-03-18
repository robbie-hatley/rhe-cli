#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Alternate solution in Perl for The Weekly Challenge 365-2,
written by Robbie Hatley on Tue Mar 17, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 365-2: Valid Token Counter
Submitted by: Mohammad Sajid Anwar
You are given a sentence. Write a script to split the given
sentence into space-separated tokens and count how many are valid
words. A token is valid if it contains no digits, has at most one
hyphen surrounded by lowercase letters, and at most one
punctuation mark (!, ., ,) appearing only at the end.

Example 1 input: $str = "cat and dog"
Expected output: 3

Example 2 input: $str = "a-b c! d,e"
Expected output: 2

Example 3 input: $str = "hello-world! this is fun"
Expected output: 4

Example 4 input: $str = "ab- cd-ef gh- ij!"
Expected output: 2

Example 5 input: $str = "wow! a-b-c nice."
Expected output: 2

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
For version 2b of this solution, I'll try to cram as much of the solution as possible into a single regexp.
I'll also be MORE strict than the rules. In THIS version, a token will have to not only obey the rules, but
must also actually look like a real English word: No blank tokens; no embedded capital letters (only the first
letter may be capitalized); no characters other than [a-zA-Z.,!-]; PLUS must obey all the given rules. For
the given examples, the results will be the same; but for edge cases, the results may be dramatically from
versions 365-2 and 365-2a.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of double-quoted sentences, in proper Perl syntax, like so:

./ch-2b.pl '("Robbie made a regexp, which is good-!", "--skew --tiger --bat", "HE sha,ved hIs fa8ce.")'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

sub cwlt {grep {/^[a-zA-Z][a-z]*(?:(?<=[a-z])-(?=[a-z]))?[a-z]*[.,!]?$/} split / /, shift}

my @strings = @ARGV ? eval($ARGV[0]) :
(
   "cat and dog",              # Expected output: 3
   "a-b c! d,e",               # Expected output: 2
   "hello-world! this is fun", # Expected output: 4
   "ab- cd-ef gh- ij!",        # Expected output: 2
   "wow! a-b-c nice.",         # Expected output: 2
);

for my $string (@strings) {
   print "\n";
   my $vtc = cwlt($string);
   print "Sentence = \"$string\"\n";
   print "Count of valid tokens = $vtc\n";
}
