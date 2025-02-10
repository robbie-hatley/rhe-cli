#!/usr/bin/env perl

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# "primes-up-to.pl"
# Prints all prime numbers up-to-and-including the positive integer given by
# the first command-line argument. (All other arguments are ignored. If the
# first argument isn't a positive integer > 1, won't print anything.
# Author: Robbie Hatley.
# Edit history:
#   Fri Jan 19, 2018: Wrote it.
########################################################################################################################

use v5.32;

use RH::Math;

my $db = 0;
my $UpTo;
my @Primes = ();
my $i;
if (1 != scalar @ARGV || !(is_positive_integer($ARGV[0])) || $ARGV[0] < 2)
{
   say "This program requires exactly one command-line argument,";
   say "which must be an integer > 1; this program will then print";
   say "all prime numbers not greater than the given number.";
   exit 666;
}
$UpTo = 0 + $ARGV[0];
say "In \"primes-up-to.pl\". \$UpTo = $UpTo" if $db;
@Primes = primes_up_to($UpTo);
say for @Primes;
exit 0;
