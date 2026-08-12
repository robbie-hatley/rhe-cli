#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solution in Perl for The Weekly Challenge 386-1,
written by Robbie Hatley on Mon Aug 10, 2026.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 386-1: Reverse Base
Submitted by: Mohammad Sajid Anwar
You are given a string representing a number, and an integer
specifying the base of that representation. Write a function
to convert this string to an integer. (For bases greater than
10, use characters A-Z, a-z, + and / in that order.)

(See "# INPUTS:" section below for examples.)

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
This is basically a repeat of 384, so I'll just re-use that solution, which uses the base conversion
routines in Math::BigInt. Though, I'll have to make some minor tweaks to allow for the collation sequence
specified in 386.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is from @ARGV or default inputs. If using @ARGV, provided one-or-more space-separated single-quoted
command-line arguments. Each argument must consist of the following 3 space-separated items:
1. base_to_be_converted_FROM (integer in 2-to-75 range)
2. base_to_be_converted_TO   (integer in 2-to-75 range)
3. number_to_be_converted

For example:
./ch-1.pl '25 7 g84j' '9 13 4807' '74 75 \6>mdW'

Output is to STDOUT and will be each input followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS, MODULES, AND SUBS:

   # Pragmas and modules:
   use v5.42;                        # Latest Perl as of this writing.
   use utf8::all;                    # Use UTF-8 for everything.
   use Math::BigInt 'lib' => 'GMP';  # Provides unlimited precision and high speed.

   # Set collation sequence:
   my $colseq =
      '0123456789'
     .'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     .'abcdefghijklmnopqrstuvwxyz'
     .'+/\<>~!@#$%^&';

   # Convert a number from one base to another (both bases in 2-to-75 range):
   sub base ( $base1 , $base2, $num ) {
      my $sign = '';
      if ('-' eq substr $num, 0, 1) {$sign = substr $num, 0, 1, ''}
      return $sign.Math::BigInt->from_base($num, $base1, $colseq)->to_base($base2, $colseq);
   }

# ------------------------------------------------------------------------------------------------------------
# INPUTS:
my @strings = @ARGV ? @ARGV :
(
   # Example 1 input:
   '2 10 101010',
   # Expected output: 42

   # Example 2 input:
   '16 10 EEADEE',
   # Expected output: 15642094

   # Example 3 input:
   '8 10 755',
   # Expected output: 493

   # Example 4 input:
   '36 10 1BRJB',
   # Expected output: 2228519

   # Example 5 input:
   '64 10 7MyqL',
   # Expected output: 123456789

   # Example #6 input:
   '62 67 -jIU9Mt3g',
   # Expected output: -QLX06tfM
);

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:

# Initialize line counter:
my $n = 0;

# Perform conversions:
for my $string (@strings) {
   # Increment conversion counter:
   ++$n;

   # Nix leading whitespace:
   $string =~ s/^\s+//;

   # Nix trailing whitespace:
   $string =~ s/\s+$//;

   # Get arguments:
   my @args = split /\s+/, $string;

   # Verify correct number of arguments:
   3 != scalar(@args)
   and warn "Error in conversion #$n: Number of space-separated arguments is not 3.\n"
           ."(Conversion #$n = \"$string\".)"
           ."(Should be base1 base2 number_to_be_converted)\n"
   and next;

   # Store arguments in variables:
   my ($b1, $b2, $x) = @args;

   # Verify $b1 is in-range:
   $b1 !~ m/^[1-9][0-9]*$/ || $b1 < 2 || $b1 > 75
   and warn "Error in conversion #$n: First base (\"$b1\") must be a decimal integer 2-75.\n"
   and next;

   # Force $b1 to be numeric:
   $b1 = 0 + $b1;

   # Verify $b2 is in-range:
   $b2 !~ m/^[1-9][0-9]*$/ || $b2 < 2 || $b2 > 75
   and warn "Error in conversion #$n: Second base (\"$b2\") must be a decimal integer 2-75.\n"
   and next;

   # Force $b2 to be numeric:
   $b2 = 0 + $b2;

   # Verify that $x is valid:
   $x !~ m/\A0\z|\A-?[1-9A-Za-z+\/\\<>~!@#$%^&][0-9A-Za-z+\/\\<>~!@#$%^&]*\z/
   and warn "Error in conversion #$n: number_to_be_converted (\"$x\") contains invalid characters.\n"
   and next;

   # Call base-conversion subroutine and print result:
   my $out = base($b1, $b2, $x);
   printf("Conversion #%d: %10s converted from base %2d to base %2d = %10s\n", $n, $x, $b1, $b2, $out);
}
