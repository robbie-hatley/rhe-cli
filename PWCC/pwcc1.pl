#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge ###-1,
written by Robbie Hatley on Dow Mon Dm, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task ###-1: Words In-Common
Submitted by: Robbie Hatley.
Write a script which, given a list of two-to-ten lists of words,
prints which words are in-common between all lists.

(See "# INPUTS:" section below for examples.)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
To solve this problem, I use a hash, keyed by words and with binary numbers as values. Each time a word is
seen, the 1 bit of it's value in the hash is set if it's from list 1, or the 2 bit if from list 2, etc.

--------------------------------------------------------------------------------------------------------------
IO NOTES:

Input is via either default data or @ARGV. If using @ARGV, provide one-or-more space-separated single-quoted
arguments. Each argument must be a comma-separated sequence of two-to-ten space-separated lists of words.
For example:

./ch-1.pl ' rat bat cat , pig cow horse ' ' Sam Bob Sue , Jacob Sam Nelda '

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.36;
   use utf8::all;
   $"=', ';

   # Which words are in-common between multiple lists?
   sub in_common ( $aref ) {
      # How many lists do we have?
      my $n = scalar @$aref;
      # Make a hash indicating where words were seen
      # by using place value within binary numbers:
      my %seen;
      for ( my $idx = 0 ; $idx < $n ; ++$idx ) {
         my $list_ref = $aref->[$idx];
         foreach my $word (@$list_ref) {
            $seen{$word} |= 1<<$idx;
         }
      }
      # Make a list of in-common words:
      my @ic = ();
      foreach my $word (sort keys %seen) {
         if ( 2**$n-1 == $seen{$word} ) {
            push @ic, $word;
         }
      }
      # Return results:
      return @ic;
   }

   # Trim non-glyph characters from the front and back of a string:
   sub trim_nonglyph ( $s ) {
      $s =~ s/\A[\pZ\p{Cc}\p{Cf}]*(.*?)[\pZ\p{Cc}\p{Cf}]*\z/$1/sr;
   }

   # Parse lists of lists:
   sub parse_argv_2 ( @bash_args ) {
      my @args = ();
      foreach my $bash_arg (@bash_args) {
         my @lst_strs = map {trim_nonglyph $_} split ',', $bash_arg;
         push @args, [map {[split /\s+/, $_]} @lst_strs];
      }
      return @args;
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @arrays = @ARGV ? parse_argv_2(@ARGV) :
(
   [["dog", "cat", "pig"], ["cat", "snake", "ant"], ["snake", "cat"]],
   [["Bob", "Sam", "Susan", "Nelda"], ["Glen", "Sam", "Albert", "Nelda", "Ellen"]],
   [[17, 37, 8, 5, 2], [3, 5, 17, 9, 42, 57]],
   [["baseball", "polo"],["curling", "baseball", "fishing"],["baseball", "darts"],["soccer","baseball"]],
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
for my $aref (@arrays) {
   say '';
   say 'Lists:';
   say "@$_" for @$aref;
   if (scalar @$aref <  2) {warn "Error: Too-few  lists (should be 2-10).\n";next;}
   if (scalar @$aref > 10) {warn "Error: Too-many lists (should be 2-10).\n";next;}
   my @common = in_common($aref);
   say "Words in-common = (@common)";
}
