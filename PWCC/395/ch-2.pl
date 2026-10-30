#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:

Solution in Perl for The Weekly Challenge 395-2,
written by Robbie Hatley on Dow Mon Dm, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:

Task 395-2: Word Squares
Submitted by: Mohammad Sajid Anwar
You are given a list of equal lengths words. Write a script to
arrange a set of words into a grid that reading across any row
gives the exact same word as reading down its corresponding
column.

(See "# INPUTS:" section below for examples.)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:

This is just a matter of using the "variations" routine from CPAN module "Algorithm::Combinatorics" to find
all l-permutations of a given set of words and see if any result in a valid word square. (There might be
lower-complexity methods, but this approach works well for small numbers and sizes of words.)

--------------------------------------------------------------------------------------------------------------
IO NOTES:

Input is via either default data or @ARGV. If using @ARGV, provide one-or-more space-separated single-quoted
arguments. Each argument must be a comma-separted list of words. The lengths of the words must all be the same
and the number of words must be at least as great as the length of the words. For example:

./ch-2.pl 'hat,agr,tbq' 'hat, agr, trq'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.40;
   use utf8::all;
   use Algorithm::Combinatorics 'variations';
   $"=', ';

   # Try to make a word square:
   sub word_square ( $aref ) {
      my $l = length($aref->[0]);
      my $i = variations($aref, $l);
      # Return the first $n-permutation we find which is
      # a valid $l x $l word square:
      PERM: while ( my $p = $i->next() ) {
         # Reject this proposed word square unless
         # sqr[x,y] eq sqr[y,x] for each (x,y):
         for    my $y (0..$l-1) {
            for my $x (0..$y-1) {
               next PERM unless
                  substr($p->[$x], $y, 1)
                  eq
                  substr($p->[$y], $x, 1);
            }
         }
         # If we get to here, @rows is our first valid
         # word square, so return it:
         return @$p;
      }
      # If we get to here, no word squares can be made,
      # so return an empty list:
      return ();
   }

   # Is a given array ref valid?
   sub valid ( $aref ) {
      # $aref must be a ref to an array:
      return false unless 'ARRAY' eq reftype $aref;
      # The array must not be empty:
      my $n = scalar @$aref;
      return false unless $n >= 1;
      # The 0th element of the array must not be empty:
      my $l = length $$aref[0];
      return false unless $l >= 1;
      # All of the strings in the array must be
      # of the same length:
      for ( my $i = 1 ; $i <= $#$aref ; ++$i ) {
         return false unless length($$aref[$i]) == $l;
      }
      # There must be at least as many array elements
      # as there are characters per string:
      return false unless $n >= $l;
      # If we get to here, all tests pass:
      return true;
   }

   # Parse lists of strings:
   sub parse_argv_1 ( @bash_args ) {
      my @args = ();
      foreach my $bash_arg (@bash_args) {
         push @args, [map {trim $_} split /,/, $bash_arg, -1];
      }
      return @args;
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? parse_argv_1(@ARGV) :
(
   [ 'MA',    'AM',    'MY',    'ME'             ], # MA    AM
   [ 'SUN',   'USE',   'NET',   'SEE',  'TEN'    ], # SUN   USE   NET
   [ 'BOAT',  'TEAL',  'AREA',  'TSAR',  'OGRE'  ], # BOAT  OGRE  AREA  TEAL
   [ 'CARD',  'AREA',  'REAR',  'DART'           ], # CARD  AREA  REAR  DART
   [ 'HEART', 'TREND', 'EMBER', 'RESIN', 'ABUSE' ], # HEART EMBER ABUSE RESIN TREND
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
for my $aref (@arrays) {
   say '';
   say "Words = (@$aref)";
   if ( !valid($aref) ) {
      warn "Error: The words must all be the same length,\n"
          ."and the number of words must be >= word length.\n";
      next;
   }
   my @rows = word_square($aref);
   if ( @rows ) {
      say "Word square:";
      say for @rows;
   }
   else {
      say "No word square found.";
   }
}
