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
For version 2a of this solution, I'll try to cram as much of the solution as possible into a single regexp.
I'll also

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of double-quoted sentences, in proper Perl syntax, like so:

./ch-2a.pl '("Robbie ran 9 times,, around the track!", "--skew --tiger -- bat", "he sha,ved his face")'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

sub cwlt {grep {/^[^0-9.,!-]*(?:[a-z]-[a-z])?[^0-9.,!-]*[.,!]?$/} split / /, shift}

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
