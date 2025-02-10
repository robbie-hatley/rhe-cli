#!/usr/bin/env perl
# hailstone.pl
# Prints The Hailstone Sequence for a given positive-integer seed,
# then prints the Total Stopping Time (minimum index for which
# value of current element is 1).
use v5.38;

# Bail if number of arguments isn't 1:
exit if 1 != scalar @ARGV;

# Get argument:
my $x=$ARGV[0];

# Bail if argument isn't a positive integer:
exit if $x !~ m/^[1-9]\d*$/;

# Hailstone function:
sub h ($x) {return 0 == $x%2 ? $x/2 : 3*$x+1}

# Print hailstone sequence for given seed:
my $n = 0;
while (1) {
	print("$x\n");
	last if 1 == $x;
	$x = h($x);
	++$n;
}

# Print Total Stopping Time:
say "Total Stopping Time = $n";
