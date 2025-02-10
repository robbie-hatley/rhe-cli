#!/usr/bin/env perl

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

# factorial.pl (currently identical to factorial-bfac.pl except no benchmarking)

use v5.32;
use Math::BigInt;
scalar(@ARGV) >= 1 && $ARGV[0] =~ m/^\d+$/
or die "Error: This program requires one argument, which must be a non-negative\n"
     . "integer. This program will then print the factorial of that number.\n";
my $x = $ARGV[0];
my $f = Math::BigInt->bfac($x);
say "$x! = $f";
exit 0;
