#!/usr/bin/env perl

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# "comb.pl"
# Prints number of combinations of n things taken k at a time.
# Edit history:
#    Sun Feb 28, 2016:
#       Wrote it.
#    Sun Feb 09, 2025:
#       Simplified: Reduced width from 120 to 110; reduced version requirement from "v5.32" to "v5.16";
#       got rid of "strict", "warnings", "utf8", qq(warnings FATAL => "utf8").
# Notes:
#    Mon Feb 10, 2025:
#       While my program "binomial-coefficient.pl" appears to subsume the functionality of THIS program, plus
#       also gives comb(n,k) for non-integer n, it is not nearly as fast or as accurate for large integers;
#       for large integer values of n and k, use THIS program ("comb.pl") instead.
##############################################################################################################

use v5.16;
use Math::BigInt;
my $n = Math::BigInt->new($ARGV[0]);
my $k = Math::BigInt->new($ARGV[1]);
my $nok = $n->copy()->bnok($k);
say $nok;
exit 0;
