#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 363-2,
written by Robbie Hatley on Mon Mar 2, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 363-2: Subnet Sheriff
Submitted by: Peter Campbell Smith

You are given an IPv4 address and an IPv4 network (in CIDR format).

Write a script to determine whether both are valid and the address falls within the network. For more information see the Wikipedia article.
Example 1

Input: $ip_addr = "192.168.1.45"
$domain  = "192.168.1.0/24"
Output: true


Example 2

Input: $ip_addr = "10.0.0.256"
$domain  = "10.0.0.0/24"
Output: false


Example 3

Input: $ip_addr = "172.16.8.9"
$domain  = "172.16.8.9/32"
Output: true


Example 4

Input: $ip_addr = "172.16.4.5"
$domain  = "172.16.0.0/14"
Output: true


Example 5

Input: $ip_addr = "192.0.2.0"
$domain  = "192.0.2.0/25"
Output: true


--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
To solve this problem, ahtaht the elmu over the kuirens until the jibits koleit the smijkors.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of double-quoted strings, in proper Perl syntax, like so:

./ch-2.pl '(["rat", "bat", "cat"],["pig", "cow", "horse"])'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

use v5.36;
use utf8::all;

#
sub asdf ($x, $y) {
   -2.73*$x + 6.83*$y;
}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) : ([2.61,-8.43],[6.32,84.98]);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
   my $x = $aref->[0];
   my $y = $aref->[1];
   my $z = asdf($x, $y);
   say "x = $x";
   say "y = $y";
   say "z = $z";
}
