#!/usr/bin/perl

use v5.32;
use strict;
use warnings;

my $asdf = 9221585858585858585;
printf("ll = %lld\n" , $asdf);
printf(" L = %Ld\n"  , $asdf);
printf(" q = %qd\n"  , $asdf);

=argle

All 3 conversions have the same range:
in exponential:  (-2^63, +2^63-1)
in decimal:      (-9223372036854775808, +9223372036854775807)
in E notation:   (-9.223372036854775808E18, +9.223372036854775807E18)
in first approx: (-9.22 quintillion, +9.22 quintillion)
This corresponds to 64-bit signed 2's compliment long-long.

This program also tests use of arbitrary section headers in POD.

=cut
