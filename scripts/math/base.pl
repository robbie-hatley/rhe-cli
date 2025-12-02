#!/usr/bin/env perl

# TITLE AND ATTRIBUTION:
# base.pl
# Converts positive integers from one base to another.
# "From" and "To" bases must be in the 2-62 range.
# Written by Robbie Hatley on Sat Aug 24, 2024.

# IO NOTES:
# Input is via @ARGV. First arg is "from" base (in decimal), second arg is
# "to" base (in decimal), and all subsequent args are integers to be converted.
# Output is to STDIO and will give "from" base, "to" base, input, and output.

use v5.16;
use bigint;

sub help {
   warn ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to Robbie Hatley's nifty number base converter.
   This program needs at least 3 arguments:
   The first  argument is "base to be converted from", 2-62, in decimal.
   The second argument is "base to be converted to"  , 2-62, in decimal.
   All remaining arguments are positive integers to be converted, using digits
   0-9,A-Z,a-z in increasing order of value.
   END_OF_HELP
}

for my $arg (@ARGV) {
   if ('--help' eq $arg || '-h' eq $arg) {help; exit 777;}
}

@ARGV < 3
and warn "\nError: insufficient number of arguments.\n" and help and exit 666;

for (@ARGV) {
   $_ !~ m/^-[1-9A-Za-z][0-9A-Za-z]*$|^0$|^[1-9A-Za-z][0-9A-Za-z]*$/
   and warn "\nError: invalid characters in one-or-more arguments.\n" and help and exit 666;
}

my $arg1 = shift @ARGV;
$arg1 !~ m/^[1-9][0-9]*$/ || $arg1 < 2 || $arg1 > 62
and warn "\nError: First  base must be decimal integer 2-62.\n" and help and exit 666;
my $base1 = 0 + $arg1;

my $arg2 = shift @ARGV;
$arg2 !~ m/^[1-9][0-9]*$/ || $arg2 < 2 || $arg2 > 62
and warn "Error: second base must be decimal integer 2-62.\n" and help and exit 666;
my $base2 = 0 + $arg2;

my %value =
(
   '0' =>  0, '1' =>  1, '2' =>  2, '3' =>  3, '4' =>  4, '5' =>  5,
   '6' =>  6, '7' =>  7, '8' =>  8, '9' =>  9, 'a' => 10, 'b' => 11,
   'c' => 12, 'd' => 13, 'e' => 14, 'f' => 15, 'g' => 16, 'h' => 17,
   'i' => 18, 'j' => 19, 'k' => 20, 'l' => 21, 'm' => 22, 'n' => 23,
   'o' => 24, 'p' => 25, 'q' => 26, 'r' => 27, 's' => 28, 't' => 29,
   'u' => 30, 'v' => 31, 'w' => 32, 'x' => 33, 'y' => 34, 'z' => 35,
   'A' => 36, 'B' => 37, 'C' => 38, 'D' => 39, 'E' => 40, 'F' => 41,
   'G' => 42, 'H' => 43, 'I' => 44, 'J' => 45, 'K' => 46, 'L' => 47,
   'M' => 48, 'N' => 49, 'O' => 50, 'P' => 51, 'Q' => 52, 'R' => 53,
   'S' => 54, 'T' => 55, 'U' => 56, 'V' => 57, 'W' => 58, 'X' => 59,
   'Y' => 60, 'Z' => 61,
);

my %repre =
(
    0 => '0',  1 => '1',  2 => '2',  3 => '3',  4 => '4',  5 => '5',
    6 => '6',  7 => '7',  8 => '8',  9 => '9', 10 => 'a', 11 => 'b',
   12 => 'c', 13 => 'd', 14 => 'e', 15 => 'f', 16 => 'g', 17 => 'h',
   18 => 'i', 19 => 'j', 20 => 'k', 21 => 'l', 22 => 'm', 23 => 'n',
   24 => 'o', 25 => 'p', 26 => 'q', 27 => 'r', 28 => 's', 29 => 't',
   30 => 'u', 31 => 'v', 32 => 'w', 33 => 'x', 34 => 'y', 35 => 'z',
   36 => 'A', 37 => 'B', 38 => 'C', 39 => 'D', 40 => 'E', 41 => 'F',
   42 => 'G', 43 => 'H', 44 => 'I', 45 => 'J', 46 => 'K', 47 => 'L',
   48 => 'M', 49 => 'N', 50 => 'O', 51 => 'P', 52 => 'Q', 53 => 'R',
   54 => 'S', 55 => 'T', 56 => 'U', 57 => 'V', 58 => 'W', 59 => 'X',
   60 => 'Y', 61 => 'Z',
);

INPUT: for my $input (@ARGV) {
   my $val = 0;
   my @digits = reverse split '', $input;
   for my $digit (@digits) {
      !defined($value{$digit}) || $value{$digit} > $base1 - 1
      and warn "\nError: $input is not a valid number in base $base1;\nMoving on to next input."
      and next INPUT;
   }
   for my $idx (0..$#digits) {
      $val += $value{$digits[$idx]} * $base1 ** $idx;
   }
   my $output = '';
   my $width = int(log($val)/log($base2));
   my $idx = 0;
   for $idx (0..$width) {
      $output .= $repre{int($val/$base2**($width-$idx))%$base2};
   }
   $output =~ s/^0+//;
   print $output;
}
