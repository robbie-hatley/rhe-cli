#!/usr/bin/env perl
# is-prime.pl
# States whether an integer argument is a prime number.
use v5.38;

# Bail if number of arguments isn't 1:
exit if 1 != scalar @ARGV;

# Get argument:
my $x = $ARGV[0];

# Bail if argument isn't an ASCII decimal representation of an integer:
exit if $x !~ m/^-[1-9]\d*$|^0$|^[1-9]\d*$/; # bail if not

# Is a given integer a prime number?
sub p ($x) {
   $x < 2      and return 0;
   2 == $x     and return 1;
   0 == $x % 2 and return 0;
   my $limit = int sqrt $x;
   for ( my $divisor = 3 ; $divisor <= $limit ; $divisor+=2 ) {
      0 == $x % $divisor and return 0;
   }
   return 1;
}

say p($x) ? "Yes" : "No";
