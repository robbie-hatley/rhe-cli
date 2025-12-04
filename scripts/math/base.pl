#!/usr/bin/env perl

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# base.pl
# Converts positive integers from one base to another. "From" and "To" bases must be in the 2-62 range.
# Bases are via @ARGV. First arg is "from" base (in decimal), second arg is "to" base (in decimal).
# Numbers to be converted are via STDIN, one per line. Output is to STDIO and will be the requested
# conversions, one per line. This script is thus a "filter".
#
# Attribution:
# Written by Robbie Hatley.
#
# Edit history:
# Sat Aug 24, 2024: Wrote it.
# Tue Dec 02, 2025: Drastically sped-up by using the "from_base" and "to_base" methods of "Math::BigInt".
#                   "From" base and "To" base are given by command-line arguments, but numbers to be
#                   converted are now input from STDIN. Chomps each input line, construes it as being
#                   one number to be converted, and outputs conversion as an output line ending in "\n".
# Wed Dec 03, 2025: Improved comments and help.
##############################################################################################################

use v5.16; # Provides "say".
use Math::BigInt 'lib' => 'GMP'; # Provides unlimited precision and high speed.

sub help {
   warn ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to Robbie Hatley's nifty number base converter.
   This program must have exactly 2 command-line arguments:
   The first  argument is "base to be converted from", 2-62, in decimal.
   The second argument is "base to be converted to"  , 2-62, in decimal.
   Integers (negative, zero, or positive) to be converted from first base to
   second base are input from STDIN. Each line is chomped then construed as being
   one number to be converted, and the converted number is output to STDOUT
   as a single line ending in "\n". This script is thus a "filter".
   Input and output use digits 0-9,A-Z,a-z in increasing order of value.
   END_OF_HELP
}

for my $arg (@ARGV) {
   if ('--help' eq $arg || '-h' eq $arg) {help; exit 777;}
}

2 != scalar(@ARGV)
and warn "Error: incorrect number of arguments.\n" and help and exit 666;

my $arg1 = shift @ARGV;
$arg1 !~ m/^[1-9][0-9]*$/ || $arg1 < 2 || $arg1 > 62
and warn "Error: First base must be decimal integer 2-62.\n" and help and exit 666;
my $base1 = 0 + $arg1; # Remove "_" and leading "0" and force "numeric".

my $arg2 = shift @ARGV;
$arg2 !~ m/^[1-9][0-9]*$/ || $arg2 < 2 || $arg2 > 62
and warn "Error: Second base must be decimal integer 2-62.\n" and help and exit 666;
my $base2 = 0 + $arg2; # Remove "_" and leading "0" and force "numeric".

while (<STDIN>) {
   chomp;
   !m/\A0\z|\A-?[1-9A-Za-z][0-9A-Za-z]*\z/
   and warn "Error: Input number contains invalid characters.\n" and next;
   my $sign = '';
   if ('-' eq substr $_, 0, 1) {$sign = substr $_, 0, 1, ''}
   say $sign.Math::BigInt->from_base($_, $base1)->to_base($base2);
}
