#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 386-2,
written by Robbie Hatley on Wed Aug 12, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 386-2: Rational Numbers
Submitted by: Mohammad Sajid Anwar
You are given two strings representing non-negative rational
numbers. Write a script to return true if the two given rational
numbers are same, otherwise false.

(See "# INPUTS:" section below for examples.)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
I have no idea of how to discern integers m and n satisfying m/n="first_group.second_group(repetition_group)".
So I won't go down that infinite rabbit hole. Instead, I'll use an approximation approach. I'll do this:
use Math::BigFloat 'lib' => 'GMP'; # For unlimited precision and high speed.
Math::BigFloat->accuracy(3000);    # For 3000-significant-figure accuracy
I'll then expand all repetition groups x55, then if the two given numbers differ by less than 1e-50 I'll call
them "equal", else I'll call them "unequal".

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either default data or via @ARGV. If using @ARGV, provide one-or-more space-separated
single-quoted arguments, with each argument consisting of a space-separated pair of non-negative rational
numbers (terminating decimals such as "33.876" or non-terminating decimals such as "42.1(857)").

Example using default data:
./ch-2.pl

Example using @ARGV:
./ch-2.pl '33.876 33.(876)' '345.(9) 346' '97.(3587462) 97.35(8746235)'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   use v5.42.2;                       # Use latest Perl as of this writing.
   use utf8::all;                     # Use the UTF-8 transformation of Unicode for all text.
   use Math::BigFloat 'lib' => 'GMP'; # For unlimited precision and high speed.
   Math::BigFloat->accuracy(3000);    # For 3000-significant-figure accuracy
   $"=', ';                           # Use ', ' for separating interpolated list items in "double-quotes".

   # Are two given rational numbers equal?
   sub equal ( $m, $n ) {
      # Make expanded version of $m:
      (my $exp1 = $m) =~ s/\((\d+)\)/$1x55/eg;
      # Make expanded version of $m:
      (my $exp2 = $n) =~ s/\((\d+)\)/$1x55/eg;
      # Make BigFloat version of $exp1:
      my $num1 = Math::BigFloat->new($exp1);
      # Make BigFloat version of $exp2:
      my $num2 = Math::BigFloat->new($exp2);
      # Make BigFloat version of '1e-50':
      my $small = Math::BigFloat->new('1e-50');
      # Make a copy of $num1 called "diff":
      my $diff = $num1->copy();
      # Get the absolute value of the difference $num1-$num2:
      $diff->bsub($num2)->babs();
      # Return 1 if difference between the two inputs is < 1e-25:
      return $diff->blt($small);
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @strings = @ARGV ? @ARGV :
(
   '   0.(12)      0.(121)     ', # false
   '   0.1(23)     0.12(32)    ', # true
   '   0.1(234)    0.12(342)   ', # true
   '   12.99(99)   13.         ', # true
   '   0.(123)     0.1(231)    ', # true
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
for my $string (@strings) {
   say '';
   # Nix newline (if any):
   chomp $string;
   # Nix leading whitespace:
   $string =~ s/^\s+//;
   # Nix trailing whitespace:
   $string =~ s/\s+$//;
   # Get arguments:
   my @args = split /\s+/, $string;
   # Bail if number of arguments isn't 2:
   2 != scalar(@args)
   and warn "Error: number of arguments was not 2.\n"
   and next;
   # Store arguments in variables:
   my ($m, $n) = @args;
   # Announce arguments:
   say "First number = $m  Second number = $n";
   # Are these equal?
   my $eq = equal($m,$n);
   # Announce result:
   $eq
   and say "These are equal."
   or  say "These are unequal.";
}
