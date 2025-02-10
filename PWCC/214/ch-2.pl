#!/usr/bin/env -S perl -CSDA

=pod

------------------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

------------------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
ch-2.pl
Robbie Hatley's Perl solutions for The Weekly Challenge 214-2.
Written by Robbie Hatley on Tue Apr 25, 2023.

------------------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 2: Collect Points
Submitted by: Mohammad S Anwar
You are given a list of numbers. You will perform a series of removal operations. For each operation, you remove from
the list N (one or more) equal and consecutive numbers, and add to your score N × N. Determine the maximum possible
score.

Example 1:  Input: @numbers = (2,4,3,3,3,4,5,4,2)  Output: 23
We see three 3's next to each other so let us remove that first and collect 3 x 3 points.
So now the list is (2,4,4,5,4,2).
Let us now remove 5 so that all 4's can be next to each other and collect 1 x 1 point.
So now the list is (2,4,4,4,2).
Time to remove three 4's and collect 3 x 3 points.
Now the list is (2,2).
Finally remove both 2's and collect 2 x 2 points.
So the total points collected is 9 + 1 + 9 + 4 => 23.

Example 2:  Input: @numbers = (1,2,2,2,2,1)  Output: 20
Remove four 2's first and collect 4 x 4 points.
Now the list is (1,1).
Finally remove the two 1's and collect 2 x 2 points.
So the total points collected is 16 + 4 => 20.

Example 3:  Input: @numbers = (1)  Output: 1

Example 4:  Input: @numbers = (2,2,2,1,1,2,2,2)  Output: 40
Remove two 1's = 2 x 2 points.
Now the list is (2,2,2,2,2,2).
Then reomove six 2's = 6 x 6 points.

------------------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
As with any "Determine the maximum possible score" problems, lacking a mathematical proof, I'm dubious as to whether
it's even possible to know if one's score is "maximum" or not.

That being said, I think one algorithm that should generate some high scores (though I have no proof that they will be
"maximum possible") is as follows: remove the least-abundant numbers first, then the next-least abundant, etc,
removing the most-abundant last. That should give high (maximal? not?) NxN scores. Later note: No, that's not always
maximal, as examples 2 and 4 show. The "fracturedness" of any one same-value subset matters.

About the only way I can see that is GUARANTEEDED to produce maximal score is,
use an n-ary tree, pursue ALL possible paths from full set to empty set, tally score
for each path, then find maximum of recorded scores.

------------------------------------------------------------------------------------------------------------------------
INPUT / OUTPUT NOTES:

Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
'single-quoted' array of arrays in proper Perl syntax.

Output is to STDOUT.

=cut

# ----------------------------------------------------------------------------------------------------------------------
# PRELIMINARIES:
use v5.36;
use strict;
use warnings;
use utf8;
use Time::HiRes 'time';
$"=', ';

# ----------------------------------------------------------------------------------------------------------------------
# SUBROUTINES:

# ----------------------------------------------------------------------------------------------------------------------
# DEFAULT INPUTS:
my @arrays =
(
   [2,4,3,3,3,4,5,4,2],
   [1,2,2,2,2,1],
   [1],
   [2,2,2,1,1,2,2,2]
);

# ----------------------------------------------------------------------------------------------------------------------
# NON-DEFAULT INPUTS:
if (@ARGV) {@arrays = eval($ARGV[0]);}

# ----------------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
{ # begin main
   my $t0 = time;
   say "Stub.";

   my $µs = 1000000 * (time - $t0);
   printf("\nExecution time was %.3fµs.\n", $µs);
   exit 0;
} # end main
