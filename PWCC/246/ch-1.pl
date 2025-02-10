#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

--------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
Solutions in Perl for The Weekly Challenge 246-1.
Written by Robbie Hatley on Mon Dec 04, 2023.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 246-1: 6 out of 49
Submitted by: Andreas Voegele
6 out of 49 is a German lottery. Write a script that outputs six
unique random integers from the range 1 to 49.

Example 1:
Input: (none)
Output: (3, 10, 11, 22, 38, 49)


--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
I elect to assume that "random" means "pseudo-random" rather than "true-random". For games, pseudo-random
numbers should be fine; only high-end cryptography actually needs true-random numbers. So I'll use Perl's
built-in "rand" function to generate 6 unique pseudo-random numbers in the range 1-49. And to make sure
they're unique, instead of comparing each newly-generated pseudo-random number to every number currently in
my array, I'll use a hash, which should be faster.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input:  This program take no inputs.
Output: Output is to STDOUT and will be 6 unique random integers in the range 1..49.

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

# Generate 6 unique pseudo-random integers in the range 1..49:
sub six_out_of_fortynine {
   my @six;
   my %hash;
   while ( scalar(@six) < 6 ) {
      my $r = int(rand 49) + 1;
      !defined $hash{$r} and push @six, $r and $hash{$r} = 1;
   }
   return @six;
}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
say '(' . join(', ', six_out_of_fortynine) . ')';
exit;

# ------------------------------------------------------------------------------------------------------------
# DETERMINE AND PRINT EXECUTION TIME:
END {printf("\nExecution time was %.0fµs.\n", 1000000 * (time - $t0))}
__END__
