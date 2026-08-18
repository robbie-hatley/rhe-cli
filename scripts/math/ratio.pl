#!/usr/bin/env perl
##############################################################################################################
# ratio.pl
# Given a rational number in the form "37.836(5472)", print the corresponding ratio of integers.
# Written by Robbie Hatley.
# Edit history:
# Thu Aug 13, 2026: Wrote it.
##############################################################################################################

# Pragmas and modules:
use v5.36;                       # For the "signatures" feature.
use utf8::all;                   # Use the UTF-8 transformation of Unicode for all text.
use Math::BigRat 'lib' => 'GMP'; # For unlimited-precision high-speed rational numbers.

# Convert a string representation into a Math::BigRat number:
sub rat ( $s ) {
   $s =~ m/^(\d+)(?:\.(?:(\d*)(?:\((\d+)\))?)?)?$/;
   my ($int, $nonrep, $rep) = ($1, $2 // '', $3 // '');
   my ($ln, $lr) = (length($nonrep), length($rep));
   my $r = Math::BigRat->new($int);
   if ($ln > 0) {
      $r->badd(Math::BigRat->new($nonrep, '1'.'0'x$ln));
   }
   if ($lr > 0) {
      $r->badd(Math::BigRat->new($rep, '9'x$lr.'0'x$ln));
   }
   return $r;
}

# Make sure we have one argument:
if ( 1 != scalar(@ARGV) ) {
   die "Error: Wrong number of arguments. Please provide one argument\n"
      ."which must be a rational number in \"36.42(82)\" format.\n";
}

# Store argument in variable $s:
my $s = $ARGV[0];

# Make sure argument is valid:
if ( $s !~ m/^(\d+)(?:\.(?:\d*(?:\(\d+\))?)?)?$/ ) {
   die "Error: \"$s\" is not a rational number. Please provide one argument\n"
      ."which must ber a rational number in the \"36.42(82)\" format.\n";
}

# Generate a Math::BigRat object from argument:
my $r = rat($s);

# Print ratio:
say $r->bfstr();
