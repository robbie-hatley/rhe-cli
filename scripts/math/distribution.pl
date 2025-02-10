#!/usr/bin/env perl

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# distribution.pl
# Dumps a set of numbers into 100 equal-subinterval bins, with the 100 bins spanning the interval from min to
# max, then prints how many of the numbers ended up in each bin. Numbers must be in a file (or piped, or
# redirected) with any number of numbers per line, separated by commas and/or whitespace.
# Edit history:
#    Tue Nov 09, 2021:
#       Refreshed colophon, title card, and boilerplate. Also fixed some bugs. Now ignores garbage
#       (non-number) lines, and now works even if some bins are empty.
#    Sun Feb 09, 2025:
#       Heavily refactored: Changed encoding from Unicode/UTF-8 to ASCII; reduced width from 120 to 110;
#       reduced version requirement from "v5.32" to "v5.16"; can now have multiple numbers per line separated
#       by commas and/or whitespace; got rid of "switch"; got rid of "Sys::Binmode"; and now using fewer
#       top-level variables.
##############################################################################################################

use v5.16;
use utf8;
use Scalar::Util qw(looks_like_number);

# Debug?
my $db = 0;
for ( my $i = 0 ; $i < scalar(@ARGV) ; ++$i ) {
   if ('-e' eq $ARGV[$i] || '--debug' eq $ARGV[$i]) {
      $db = 1;
      splice @ARGV, $i, 1;
      --$i;
   }
}

# Pre-declare all top-level variables we'll be using:
my @numbers = (); # Numbers to be distributed.
my @bins    = (); # 100 equal-subinterval bins to hold numbers.
my $min     =  0; # Minimum number.
my $max     =  0; # Maximum number.
my $range   =  0; # Range of numbers (max-min).

# Get numbers from <>:
foreach my $line (<>) {
   my @numbers_from_line = split /[,\s]+/, $line;
   foreach my $number (@numbers_from_line) {
      if (!looks_like_number($number)) {
         warn "Not a number: $number\n";
         next;
      }
      else {
         warn "Number: $number\n" if $db;
         push @numbers, $number;
      }
   }
}

# Print numbers to STDERR if debugging:
warn("Numbers = ", join(',', @numbers), "\n") if $db;

# Get min, max, and range:
$min   = $numbers[0];
$max   = $numbers[0];
$range = 0;
for my $x (@numbers) {
   $min = $x if $x < $min;
   $max = $x if $x > $max;
}
$range = $max-$min;
warn "min   = $min\n"   if $db;
warn "max   = $max\n"   if $db;
warn "range = $range\n" if $db;

# Fill @bins with 100 refs to empty anonymous arrays:
for ( my $idx = 0 ; $idx < 100 ; ++$idx) {
   $bins[$idx]=[];
}

# Fill bins with numbers:
for my $number (@numbers) {
   my $idx = int(100*($number-$min)/$range);
   if ($idx <  0) {$idx = 0;}
   if ($idx > 99) {$idx = 99;}
   push @{$bins[$idx]}, $number;
}

# Print results in Perl "hash" nomenclature (using "=>"):
for ( my $idx = 0 ; $idx < 100 ; ++$idx ) {
   printf("%2d => %d\n", $idx, scalar(@{$bins[$idx]}));
}
