#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 350-2,
written by Robbie Hatley on Dow Mon Dm, 2025.

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
To solve this problem, I'll make three subs: "str_perms ( $s )" (returning all permutations of a string),
"witness ( $x , $y )" (returning integer $k such that $x*$k == $y, or 0 if no such integer exists),
and "partners ( $i , $j, $c )" (returning all integers in the range $i..$j which are part of $c-or-more
"shuffle pairs".

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of 3 positive integers, with the second integer greater than the first within
each inner array, in proper Perl syntax, like so:
./ch-2.pl '([3752, 8754, 3], [187956, 497856, 4])'
Within each inner array, first number is "from", second number is "to", and third number is "count", according
to the definitions of those terms given in this problem's description (see "PROBLEM DESCRIPTION:" above).

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use utf8::all;
   #use Math::Combinatorics;

   # Return all permutations of a string which do not start with the character '0':
   sub str_perms_niz ( $s ) {
      state $lor = 0;                            # Level Of Recursion
      my $n = length $s;                         # Length of string.
      my @p = ();                                # Partial permutations.
      if (1==$n) {push @p, $s;return @p}         # Single-character string has exactly 1 permutation.
      for my $idx (0..$n-1) {                    # For each possible initial character.
         if (0 == $lor) {                        # If we're at top level of recursion,
            next if '0' eq substr $s, $idx, 1}   # skip this inital digit if its '0'.
         my $rem = $s;                           # Copy of $s from which current character will be removed.
         my $ini = substr $rem, $idx, 1, '';     # Store initial character in $ini, remnant in $rem.
         ++$lor;                                 # About to recurse.
         my @ppp = str_perms_niz($rem);          # Permutations of $rem.
         --$lor;                                 # Returned from recursion.
         my @pp = map {"$ini$_"} @ppp;           # All partials starting with $ini.
         push @p, @pp}                           # Add partial partials to partitals.
      return @p}                                 # Return partial permutations (complete if at top level).

=pod

   # Return all permutations of a string:
   sub str_perms ( $s ) {
      my @a = split //, $s;                      # Array form of integer.
      my @p = permute(@a);                       # Permutations of array.
      return map {join '', @$_} @p}              # Permutations of string.

=cut

   # What integers $x exist from $i through $j such that $x is a member of at least $c shuffle pairs?
   sub partners ( $i , $j , $c ) {
      $i = 0 + $i;                           # Strip "_" marks and leading zeros from integers.
      $j = 0 + $j;                           # Strip "_" marks and leading zeros from integers.
      $c = 0 + $c;                           # Strip "_" marks and leading zeros from integers.
      my @p = ();                            # Integers range $i..$j with $c-or-more shuffle-pair partners.
      for my $x ( $i .. $j ) {               # For each integer in the range $i..$j:
         say "x = $x" if 0==$x%1000;
         my $cnt = 0;                        # How many partners does $x have?
         my @sp = str_perms_niz($x);         # Get all string permutations of $x not starting with '0'.
         for my $p (@sp) {                   # For each such permutation:
            next if '0' eq substr $p, 0, 1;  # Skip this initial character if it's '0'.
            next if $p == $x;                # Skip $p if it's the same as $x.
            next if $p>0.5*$x && $p<2.0*$x;  # Witness integer must be 2,3,4,5...
            if ($p<$x) {++$cnt if 0==$x%$p}  # Is $x divisible by $p? (in case where $p<$x).
            else       {++$cnt if 0==$p%$x}} # Is $p divisible by $x? (in case where $x<$p).
         push @p, $x if $cnt >= $c}          # Accumulate $x in @p if $cnt is $c or more.
      return @p}                             # Return list of integers in $i..$j with $c-or-more partners.

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
    my $i = $aref->[0];
    my $j = $aref->[1];
    my $c = $aref->[2];
    my $p = partners($i, $j, $c);
    say "i = $i  j = $j  c = $c  partners = $p";
}
