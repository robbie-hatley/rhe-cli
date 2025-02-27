#!/usr/bin/env perl

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# prime-regexp-test.pl
# Tests finding primes using a regexp.
# Written by Robbie Hatley.
# Edit history:
# Sat Nov 02, 2024: Wrote it.
##############################################################################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PRAGMAS, MODULES, AND SUBS:

use v5.36;

# Is $x a prime number, using conventional means?
sub is_prime_conven ($x) {
   $x < 2      and return 0;
   2 == $x     and return 1;
   0 == $x % 2 and return 0;
   my $limit = int sqrt $x;
   for ( my $divisor = 3 ; $divisor <= $limit ; $divisor+=2 ) {
      0 == $x % $divisor and return 0;
   }
   return 1;
}

# Is $x a prime number, using regexp means?
sub is_prime_regexp ($x) {
   ('R' x $x) !~ m/^.?$|^(..+?)\1+$/;
}

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "prime-regexp-test.pl". This program compares the conventional
   versus regexp methods for determining primality of integers, for all integers
   from 0 through 250,000. Any exceptions are printed. This program does not
   take any inputs, arguments, or options.
   END_OF_HELP
} # end sub help

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MAIN BODY OF PROGRAM:
for (@ARGV) {'-h' eq $_ || '--help' eq $_ and help and exit}
my @nums = 0..250_000;
say 'Comparing conventional to regexp methods for determining primality,';
say 'for all integers from 0 through 250,000....';
for (@nums) {
   0 == $_ % 10_000 and say " ... now processing index $_ ... ";
   is_prime_conven($_) && !is_prime_regexp($_) and say "$_: conventional prime but not regexp prime";
  !is_prime_conven($_) &&  is_prime_regexp($_) and say "$_: regexp prime but not conventional prime";
}
