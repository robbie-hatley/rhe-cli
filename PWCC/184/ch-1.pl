#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

--------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
Solutions in Perl for The Weekly Challenge 184-1.
Written by Robbie Hatley on Tue Nov 07, 2023.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 1: Sequence Number
Submitted by: Mohammad S Anwar
You are given list of strings in the format aa9999; ie, the first
two characters can be anything 'a-z' followed by 4 digits '0-9'.
Write a script to replace the first two characters with a sequence
starting with '00', '01', '02' etc.

Example 1:
Input:  ('ab1234', 'cd5678', 'ef1342')
Output: ('001234', '015678', '021342')

Example 2:
Input:  ('pq1122', 'rs3334')
Output: ('001122', '013334')

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
The first task will be to assure that the inputs actually DO consist of strings of the given format; I'll make
a sub called "is_aa9999" to do this. Then to do the serialization I'll make a sub called "sequence" which uses
a 3-part loop with an index "$idx" starting at 0 and incrementing by 1 each loop for the "sequence number".
Then I'll use Perl's built-in "sprintf" function to format the serialized strings.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
double-quoted array of arrays of single-quoted 6-character strings of the form xx#### (where "xx" is any two
lower-case letter and "####" is any four digits) in proper Perl syntax, like so:
./ch-1.pl "(['qg3704', 'ap9902', 'te3305'],['cat','mule','horse'],['xj2956', 'sk6810', 'xx9261'])"

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

sub is_aa9999 ($aref) {
   if ( 'ARRAY' ne ref($aref) )                 {return 0;}
   if ( scalar(@$aref) < 1    )                 {return 0;}
   for ( @$aref ) {if ( !/^[a-z]{2}[0-9]{4}$/ ) {return 0;}}
                                                 return 1;
}

sub sequence ($aref) {
   my @sequence = ();
   for ( my $idx = 0 ; $idx <= $#$aref ; ++$idx ) {
      push @sequence, sprintf("%02d%4s", $idx, substr($$aref[$idx], 2, 4));
   }
   return @sequence;
}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:

# Inputs:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   # Example 1 Input:
     ['ab1234', 'cd5678', 'ef1342'],
   # Expected Output:
   # ('001234', '015678', '021342')

   # Example 2 Input:
     ['pq1122', 'rs3334'],
   # Expected Output:
   # ('001122', '013334')
);

# Main loop:
for my $aref (@arrays) {
   say '';
   say 'Original  Array = (', join(', ', map {"\"$_\""} @$aref   ), ')';
   if ( !is_aa9999($aref) ) {
      say 'ERROR: Not an array of "aa9999" strings; skipping to next.';
      next;
   }
   my @sequence = sequence($aref);
   say 'Sequenced Array = (', join(', ', map {"\"$_\""} @sequence), ')';
}
exit;

# ------------------------------------------------------------------------------------------------------------
# DETERMINE AND PRINT EXECUTION TIME:
END {my $µs = 1000000 * (time - $t0);printf("\nExecution time was %.0fµs.\n", $µs)}
__END__
