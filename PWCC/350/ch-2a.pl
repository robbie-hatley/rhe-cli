#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
ALTERNATE solution, in Perl, for The Weekly Challenge 350-2;
written by Robbie Hatley on Thu Dec 04, 2025.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 350-2: Shuffle Pairs
Submitted by: E. Choroba
If two integers A <= B have the same digits but in different
orders, we say that they belong to the same shuffle pair if and
only if there is an integer k such that B = A * k where k is
called the witness of the pair. For example, 1359 and 9513
belong to the same shuffle pair, because 1359 * 7 = 9513.
Interestingly, some integers belong to several different shuffle
pairs. For example, 123876 forms one shuffle pair with 371628,
and another with 867132, as 123876 * 3 = 371628,
and 123876 * 7 = 867132. Write a function that for a given $from,
$to, and $count returns the number of integers $i in the range
$from <= $i <= $to that belong to at least $count different
shuffle pairs.

PS: Inspired by a conversation between Mark Dominus and
Simon Tatham at Mastodon.

Example #1:
Input: $from = 1, $to = 1000, $count = 1
Output: 0
There are no shuffle pairs with elements less than 1000.

Example #2:
Input: $from = 1500, $to = 2500, $count = 1
Output: 3
There are 3 integers between 1500 and 2500 that belong to
shuffle pairs.
1782, the other element is 7128 (witness 4)
2178, the other element is 8712 (witness 4)
2475, the other element is 7425 (witness 3)

Example #3:
Input: $from = 1_000_000, $to = 1_500_000, $count = 5
Output: 2
There are 2 integers in the given range that belong to 5 different
shuffle pairs.
1428570 pairs with 2857140, 4285710, 5714280, 7142850, and 8571420
1429857 pairs with 2859714, 4289571, 5719428, 7149285, and 8579142
The witnesses are 2, 3, 4, 5, and 6 for both the integers.

Example #4:
Input: $from = 13_427_000, $to = 14_100_000, $count = 2
Output: 11
6 integers in the given range belong to 3 different shuffle pairs,
5 integers belong to 2 different ones.

Example #5:
Input: $from = 1030, $to = 1130, $count = 1
Output: 2
There are 2 integers between 1020 and 1120 that belong to at least
one shuffle pair:
1035, the other element is 3105 (witness k = 3)
1089, the other element is 9801 (witness k = 9)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
Alternate method a: make a hash of all partners of all integers from $from/10 through $to*10,
then just riffle through that hash and counter integers from $from through $to which have $count-or-more
partners.

Addendum: This idea is a big-O disaster. I calculate that Example 3 would take over 27 hours to complete.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of 3 positive integers, with the second integer greater than the first within
each inner array, in proper Perl syntax, like so:
./ch-2.pl '([125, 125_000, 3], [125_000, 1_250_000, 2])'
Within each inner array, first number is "from", second number is "to", and third number is "count", according
to the definitions of those terms given in this problem's description (see "PROBLEM DESCRIPTION:" above).

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use utf8::all;

   # What is the digit signature of the decimal expansion of a positive integer?
   sub sig ( $x ) {
      join '', sort split //, $x}

   # What integers $x exist from $i through $j such that $x is a member of at least $q shuffle pairs?
   sub partners ( $i , $j , $q ) {         # $i = start; $j = end; $q = quota.
      my $bot = (int $i/10)+1;             # Bottom of range in which to look for partners.
      my $top = (int $j*10)-1;             # Top    of range in which to look for partners.
      my %pt;                              # Partners Table.
      for my $l ($bot..$top) {             # For each key from $bot to $top,
         $pt{$l} = []}                     # assign an empty anonymous array as value.
      for    my $m ($bot..int($top/2)) {   # Partners must differ by at least a factor of 2.
         for my $n (2*$m..$top)   {        # Partners must differ by at least a factor of 2.
            if (0==$n%$m) {                # If $m and $n have a common factor,
               if (sig($m) eq sig($n)) {   # and if they also have a common signature,
                  push @{$pt{$m}}, $n;     # $m has $n as a partner
                  push @{$pt{$n}}, $m}}}}  # $n has $m as a partner
      my $p = 0;                           # $p = integers in $i..$j with $q-or-more shuffle-pair partners.
      for my $x ( $i .. $j ) {             # For each integer in the range $i..$j,
         ++$p if scalar(@{$pt{$x}}) >= $q} # increment partners counter if this integer meets our quota.
      $p}                                  # Return number of integers in $i..$j with $q-or-more partners.

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   [          1,       1000, 1 ], # Expected output:  0
   [      1_500,       2500, 1 ], # Expected output:  3
   [  1_000_000,  1_500_000, 5 ], # Expected output:  2
   [ 13_427_000, 14_100_000, 2 ], # Expected output: 11
   [      1_030,      1_130, 1 ], # Expected output:  2
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$"=', ';
for my $aref (@arrays) {
    say '';
    my $i = $aref->[0];           # Begin range.
    my $j = $aref->[1];           # End   range.
    my $q = $aref->[2];           # Partner quota.
    my $p = partners($i, $j, $q); # Number of integers in given range which meet partner quota.
    say "Number of numbers from $i through $j which have $q or more shuffle-pair partners = $p";
}
