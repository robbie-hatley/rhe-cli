#!/usr/bin/env perl
# rand8.pl
# Prints strings of 8 random lower-case English letters. By default it prints 10 strings, but if
# 1-or-more arguments are given, and if the first argument has a positive-integer numeric value in the
# 1-1000 range, "rand8" will print that number of strings.
# Edit History:
# Wed Oct 28, 2020: Wrote it.
# Sun Apr 27, 2025: Simplified.
use v5.36;
use utf8::all;
my $num = @ARGV ? $ARGV[0] : 10;
map {say join '', map {chr(97 + int rand 26)} (1..8)} (1..$num)
