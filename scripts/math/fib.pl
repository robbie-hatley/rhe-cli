#!/usr/bin/env perl

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

# "fib.pl"

use v5.32;
use bignum;

@ARGV >= 1 && $ARGV[0] =~ m/^\d+$/ && $ARGV[0] >= 3
or die "Error: this program requires one argument, which must be a non-negative\n".
       "integer n >= 3. This program will then print the first n elements of\n".
       "The Fibonacci Sequence.\n";

my $n = $ARGV[0];
my $i = 1;
my $j = 1;
my $k;

printf("%125s\n", $i);
printf("%125s\n", $j);
foreach ( 3 .. $n )
{
   $k = $i + $j;
   printf("%125s\n", $k);
   $i = $j;
   $j = $k;
}
