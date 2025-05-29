#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw(exp);    # for exp() function

# Calculate factorial (iteratively, for speed and clarity)
sub factorial {
    my ($n) = @_;
    return 1 if $n == 0;
    my $f = 1;
    $f *= $_ for 2..$n;
    return $f;
}

# Compute the probability of at least $n fixed points
sub prob_at_least_n_fixed_points {
    my ($n) = @_;
    my $sum = 0;
    my $e = exp(1);

    # We'll sum the tail from $n to $n+40; that's plenty for convergence
    for my $k ($n .. $n + 40) {
        my $term = 1 / (factorial($k) * $e);
        $sum += $term;
        last if $term < 1e-12;  # optional early stop for speed
    }

    return $sum;
}

# Display probabilities for n = 1 to 10
for my $n (1..10) {
    my $p = prob_at_least_n_fixed_points($n);
    printf("P(at least %2d fixed points) ≈ %.8f\n", $n, $p);
}
