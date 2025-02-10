#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

--------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
Solutions in Perl for The Weekly Challenge 186-1.
Written by Robbie Hatley on Fri Nov 10, 2023.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 1: Zip List
Submitted by: Mohammad S Anwar
You are given two list @a and @b of same size. Create a
subroutine sub zip(@a, @b) that merge the two list as shown in
the example below.

Example 1:
Input:  @a = qw/1 2 3/; @b = qw/a b c/;
Output: zip(@a, @b) should return qw/1 a 2 b 3 c/;
        zip(@b, @a) should return qw/a 1 b 2 c 3/;

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
This is incredibly simple, and there's probably a CPAN module for it, but then what would be the point? No,
I'll make a "zip" sub instead. And I won't even insist on the arrays being the same length, or even being
non-empty. (The zip of two empty arrays is just an empty array.)

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be
a double-quoted array of arrays of two qw-quoted arrays bare-word strings, in proper Perl syntax, like so:
./ch-1.pl "([[qw(Fred Barney)], [qw(cat dog)]], [[qw(1 2 3)],[qw(apple ball candy dune)]])"

Output is to STDOUT and will be each input array followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS AND MODULES USED:

use v5.38;
use strict;
use warnings;
use utf8;
use warnings FATAL => 'utf8';
use Time::HiRes 'time';

# ------------------------------------------------------------------------------------------------------------
# START TIMER:
our $t0;
BEGIN {$t0 = time}

# ------------------------------------------------------------------------------------------------------------
# SUBROUTINES:

# Zip-together two arrays of anything, of any sizes,
# even if one-or-both arrays are empty:
sub zip ($aref1, $aref2) {
   my @zipped = ();
   my $maxidx = $#$aref1; $maxidx = $#$aref2 if $#$aref2 > $#$aref1;
   for ( my $idx = 0 ; $idx <= $maxidx ; ++$idx ) {
      push @zipped, $$aref1[$idx] if $idx <= $#$aref1;
      push @zipped, $$aref2[$idx] if $idx <= $#$aref2;
   }
   return @zipped;
}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:

# Inputs:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   # Example 1 Input:
   [[qw/1 2 3/], [qw/a b c/]],
   # Expected Output:
   # qw/1 a 2 b 3 c/;
);

# Main loop:
for my $aref (@arrays) {
   say '';
   my @zipped = zip($$aref[0], $$aref[1]);
   say 'first  array = qw/', join(' ', @{$$aref[0]}), '/';
   say 'second array = qw/', join(' ', @{$$aref[1]}), '/';
   say 'zipped array = qw/', join(' ', @{zipped   }), '/';
}
exit;

# ------------------------------------------------------------------------------------------------------------
# DETERMINE AND PRINT EXECUTION TIME:
END {my $µs = 1000000 * (time - $t0);printf("\nExecution time was %.0fµs.\n", $µs)}
__END__
