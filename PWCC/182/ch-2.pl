#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

--------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
Solutions in Perl for The Weekly Challenge 182-2.
Written by Robbie Hatley on Thu Oct 12, 2023.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 2: Common Path
Submitted by: Julien Fiegehenn
Given a list of absolute Linux file paths, determine the
deepest path to the directory that contains all of them.

Example 1:
Input:
    /a/b/c/1/x.pl
    /a/b/c/d/e/2/x.pl
    /a/b/c/d/3/x.pl
    /a/b/c/4/x.pl
    /a/b/c/d/5/x.pl
Ouput:
    /a/b/c

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
My first step will be to remove the file part of each path and the final '/', leaving only the directory part.
Then I'll make note of the length of the shortest string, and only compare characters up to that index, as
characters to the RIGHT of that index can give no information regarding any directory which contains ALL given
directories. Then I'll compares the ith characters of the strings from left to right. If the ith characters
all all equal, append that character to a "$common" string, otherwise stop. When the comparison is finished
(either because a non-equal character was found or because the length limit was reached), chop all characters
to the right of the final '/' of "$common"; that will be our "deepest common path".

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
double-quoted array of single-quoted Linux paths, in proper Perl syntax, like so:
./ch-2.pl "('/home/ardvu/denva/a.txt', '/home/ardvu/echo/b.txt', '/home/gegor/sanfa/c.txt')"

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
our $t0; BEGIN {$t0 = time}

# ------------------------------------------------------------------------------------------------------------
# SUBROUTINES:

sub deepest_common_path (@array) {
   # First, get rid of the file parts of the paths:
   for (@array) {$_ =~ s#/[^/]+$#/#}
   # Now find the shortest length (because no characters to the right of this can have
   # any bearing at all on the deepest common path):
   my $n = length($array[0]);
   for (@array) {my $l = length($_);$n = $l if ($l < $n);}
   # Finally, find the deepest common path:
   my $common = '';
   # Iterate columns:
   COL: for ( my $i = 0 ; $i < $n ; ++$i ) {
      # For each column, iterate rows:
      ROW: for ( my $j = 1 ; $j <= $#array ; ++$j ) {
         # For each character, exit outer loop if it doesn't match character $i of row 0:
         if ( substr($array[$j],$i,1) ne substr($array[0],$i,1) ) {
            last COL;
         }
      } # end for each row
      # If we get to here, append character $i of row 0 to $common:
      $common .= substr($array[0],$i,1)
   } # end for each column
   # Get rid of any characters to the right of right-most '/' because they can only be
   # pieces of subdirectories which were NOT common between all given directories:
   $common  =~ s#/[^/]+$#/#;
   # Finally, return result:
   return $common;
}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:

# Inputs:
my @array = @ARGV ? eval($ARGV[0]) :
(
   '/a/b/c/1/x.pl',
   '/a/b/c/d/e/2/x.pl',
   '/a/b/c/d/3/x.pl',
   '/a/b/c/4/x.pl',
   '/a/b/c/d/5/x.pl',
);

my $common = deepest_common_path(@array);
say 'Paths:';
say for @array;
say '';
say 'Deepest common path:';
say $common;
exit;

# ------------------------------------------------------------------------------------------------------------
# DETERMINE AND PRINT EXECUTION TIME:
END {my $µs = 1000000 * (time - $t0);printf("\nExecution time was %.0fµs.\n", $µs)}
__END__
