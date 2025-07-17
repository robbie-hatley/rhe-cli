#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 329-1,
written by Robbie Hatley on Thu Jul 17, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 329-1: Counter Integers
Submitted by: Mohammad Sajid Anwar
You are given a string containing only lower case English
letters and digits. Write a script to replace every non-digit
character with a space and then return all the distinct integers
left.

Example #1:
Input: $str = "the1weekly2challenge2"
Output: 1, 2
2 is appeared twice, so we count it one only.

Example #2:
Input: $str = "go21od1lu5c7k"
Output: 21, 1, 5, 7

Example #3:
Input: $str = "4p3e2r1l"
Output: 4, 3, 2, 1

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
I think I'll approach this by first using a regular expression in a s/// statement to change each cluster of
"non-digit characters" into a single space, then split the string on spaces to a list, then use function
"none" from CPAN module "List::Util" to collect integers which haven't been collected yet, then return that
collection of unique integers.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of double-quoted strings, in proper Perl syntax, like so:

./ch-1.pl '("1r82aA17t", "bA32atT", "cCat", "1p1i2g3", "42c1oW17w42", "14ho3r17s8e0")'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use utf8::all;
   use List::Util 'none';

   # Return unique integers found in a string:
   sub unique_integers ($s) {
      $s =~ s/[^\d]+/ /g;                 # Convert each non-digit cluster to a space.
      $s =~ s/^ //; $s =~ s/ $//;         # Get rid of spaces at beginning or end.
      my @ints = split / /, $s;           # Split string on spaces to list.
      my @unique;                         # Make an array to hold UNIQUE integers.
      foreach my $int (@ints) {           # For each integer,
         if (none {$_ == $int} @unique) { #   if integer is unique,
            push @unique, $int}}          #     collect it.
      return @unique}                     # Return result.

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @strings = @ARGV ? eval($ARGV[0]) : ("the1weekly2challenge2", "go21od1lu5c7k", "4p3e2r1l");
#                   Expected outputs :         (1, 2)            (21, 1, 5, 7)    (4, 3, 2, 1)

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
foreach my $string (@strings) {
   say '';
   say "String = $string";
   my @ints = unique_integers($string);
   say "Unique integers in string = (@ints)";
}
