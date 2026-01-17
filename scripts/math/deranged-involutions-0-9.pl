#!/usr/bin/env perl
use v5.16;
use strict;
use warnings;

# We work with positions 0..9 in the string "0123456789"
my @used  = (0) x 10;   # which indices have been paired
my @pairs;              # current list of [i,j] pairs
my $count = 0;          # sanity check; should end at 945

sub gen_pairs {
    # find first unused index
    my $i;
    for ($i = 0; $i < 10; $i++) {
        last if !$used[$i];
    }

    # if i == 10, all indices are paired → build permutation
    if ($i == 10) {
        my @sigma = (0..9);  # σ(i) = i initially

        # each pair (a,b) becomes a 2-cycle: a ↔ b
        for my $p (@pairs) {
            my ($a, $b) = @$p;
            $sigma[$a] = $b;
            $sigma[$b] = $a;
        }

        my $src   = "0123456789";
        my $image = join '', map { substr($src, $sigma[$_], 1) } 0..9;
        say $image;
        $count++;
        return;
    }

    # otherwise, pair i with every unused j > i
    $used[$i] = 1;
    for (my $j = $i + 1; $j < 10; $j++) {
        next if $used[$j];
        $used[$j] = 1;
        push @pairs, [$i, $j];

        gen_pairs();

        pop @pairs;
        $used[$j] = 0;
    }
    $used[$i] = 0;
}

gen_pairs();
say STDERR "Total deranged involutions: $count";
