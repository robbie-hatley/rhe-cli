#!/usr/bin/env perl
# hex2dec.pl
# Converts non-negative decimal integers to hexadecimal with unlimited precision.
use v5.42;
use utf8::all;
use bigint 'lib'=>'GMP';
for (@ARGV) {
   if ($_ eq '-h' || $_ eq '--help') {
      say "This program converts a positive hexadecimal integer to decimal,";
      say "with unlimited precision. Present your integer as first-and-only";
      say "command-line argument, and make sure it consists only of valid";
      say "hexadecimal digits and does not begin with a 0.";
      exit;
   }
}
die "Wrong number of arguments!\n$!\n" if 1 != scalar(@ARGV);
my $arg = $ARGV[0];
die "Argument is not a positive hexadecimal integer!\n$!\n" if $arg !~ m/^[1-9a-fA-F][0-9a-fA-F]*$/;
# Make sure that our "$x" is numeric rather than text,
# and bigint rather than limited-precision:
my $x = 0 + ( '0x' . $arg);
say $x;
