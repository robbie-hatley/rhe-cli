#!/usr/bin/env -S perl -C63
# is-prime-regexp.pl
# Finds primes using a regexp.
# Written by Robbie Hatley on
# Sat Nov 02, 2024.

use utf8;

(1 != @ARGV) || ($ARGV[0] !~ m/^0$|^[1-9]\d*$/)
|| ($ARGV[0] < 2) || ($ARGV[0] > 999_999)
and die
"Must have exactly one argument, which must be a non-negative integer\n".
"greater than 1 and less than 1,000,000.\n";

('茶'x$ARGV[0]) =~ m/^.?$|^(..+?)\1+$/
and print "$ARGV[0] is composite\n"
or  print "$ARGV[0] is prime\n";
