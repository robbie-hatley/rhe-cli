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
You are given an IPv4 address and an IPv4 network (in CIDR
format). Write a script to determine whether both are valid and
the address falls within the network. For more information see
this Wikipedia article:
https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing

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
I'll first check that the two IP addresses are valid (4 dot-separated positive decimal integers in the 0-255
range), then check that the subnet is valid (a positive decimal integer in the 0-32 range). Then check that
the "$ip_addr" is in the range of the "$domain" by converting the two IP addresses to integer, then making
the subnet mask correspoding to the bitcount, then bitwise-anding the mask against the two addresses and
seeing if the results match.

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
sub asdf ( $ip_addr, $domain ) {
   ;
}

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) : ([2.61,-8.43],[6.32,84.98]);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
   say '';
}
