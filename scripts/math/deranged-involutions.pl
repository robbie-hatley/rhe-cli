#!/usr/bin/env perl
# deranged-involutions.pl
use v5.36               ; # To get the "strict", "warnings", and "signatures" features.
use utf8::all           ; # To get proper handing of Unicode and UTF-8.
use Math::Combinatorics ; # To get the "permute" function.
die "Error: Must have exactly one argument, which must be a non-empty string.\n$!\n"
unless 1 == scalar(@ARGV) && length($ARGV[0])>0;
my $string  = $ARGV[0]          ; # Original string.
my $n       = length $string    ; # Length of string.
my @chars   = split //, $string ; # String split into array of characters.
my @indices = 0..$n-1           ; # Indices for @chars.
my @perms   = permute @indices  ; # Permutations of @indices.
my $deins   = 0                 ; # Count of permutations which are deranged involutions.

# Find all deranged involutions of $string:
PERM: foreach my $perm (@perms) {
   foreach my $i (0..$n-1) {
      my $j = $perm->[$i];
      next PERM if $perm->[$j] != $i;
      next PERM if $j == $i;
   }
   ++$deins;
   say STDOUT join '', @chars[@$perm];
}
say STDERR "Found $deins deranged involutions of string \"$string\".";
