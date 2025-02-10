#!/usr/bin/perl
# hatley-primes.pl
use v5.32;
use bigint;
use RH::Math;
my $n          = 0+1;    # exponent for 30
my $candidate  = 0;      # Candidate for primeness.
my $isprime    = 0;      # Is 30^n-1 prime?
for ( $n = 1 ; $n < 100 ; ++$n )
{
   $candidate = 2**$n - 1;
   say "Candidate = $candidate";
   $isprime   = is_prime($candidate);
   printf("%100s", $candidate);
   $isprime ? printf(" is prime.\n")
            : printf(" is composite.\n");
}
