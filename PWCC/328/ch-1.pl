#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 328-1,
written by Robbie Hatley on Thu Jul 17, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 328-1: Replace all ?
Submitted by: Mohammad Sajid Anwar
You are given a string containing only lower case English
letters and "?". Write a script to replace all "?" in the given
string so that the string doesn’t contain consecutive repeating
characters.

Example 1
Input: $str = "a?z"
Output: "abz"
There can be many strings, one of them is "abz". The choices are
'a' to 'z' but we can't use either 'a' or 'z' to replace the '?'.

Example 2
Input: $str = "pe?k"
Output: "peak"

Example 3
Input: $str = "gra?te"
Output: "grabte"

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
NO set of replacements of ?s is GUARANTEED to give a string with no consecutive identical characters, because
the string may ALREADY have consecutive identical characters. All we can do is insure that our replacements
don't add more.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of double-quoted strings, in proper Perl syntax, like so:

./ch-1.pl '("ra?t", "hor?se", "roo?t")'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

use v5.36;
use utf8::all;

# Replace question marks in such a way that new pairs
# of consecutive identical characters are not created:
sub repque ($s) {
   my $n = length($s);
   my @ab=split //, 'abcdefghijklmnopqrstuvwxyz';
   foreach my $sidx (0..$n-1) {
      if ('?' eq substr $s, $sidx, 1) {
         foreach my $lidx (0..25) {
            next if $ab[$lidx] eq substr $s, $sidx-1, 1;
            next if $ab[$lidx] eq substr $s, $sidx+1, 1;
            substr $s, $sidx, 1, $ab[$lidx];
            last}}}
   return $s}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @strings = @ARGV ? eval($ARGV[0]) : ( "a?z", "pe?k", "gra?te" );
#                   Expected outputs : ( "abz", "peak", "grabte" );

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $string (@strings) {
   say '';
   say "String = $string";
   my $rq = repque($string);
   say "Repque = $rq";
}
