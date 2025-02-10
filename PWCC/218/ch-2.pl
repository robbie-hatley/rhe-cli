#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

--------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
ch-1.pl
Solutions in Perl for The Weekly Challenge 218-2.
Written by Robbie Hatley on Thu May 25, 2023.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 2: Matrix Score
Submitted by: Mohammad S Anwar

You are given a m x n binary matrix i.e. having only 1 and 0.

You are allowed to make as many moves as you want to get the highest score.

    A move can be either toggling each value in a row or column.

To get the score, convert the each row binary to dec and return the sum.
Example 1:

Input: @matrix = [ [0,0,1,1],
                   [1,0,1,0],
                   [1,1,0,0], ]
Output: 39

Move #1: con

1,1,0,0],
           [1,0,1,0],
           [1,1,0,0], ]

Move #2: convert col #3 => 101
         [ [1,1,1,0],
           [1,0,0,0],
           [1,1,1,0], ]

Move #3: convert col #4 => 111
         [ [1,1,1,1],
           [1,0,0,1],
           [1,1,1,1], ]

Score: 0b1111 + 0b1001 + 0b1111 => 15 + 9 + 15 => 39

Example 2:

Input: @matrix = [ [0] ]
Output: 1

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
This is pretty simple. Just check each word to see if it contains all of the letters from the registration string,
then output the subset of the original word set which contains those members which contain all registration letters.
I use a ranged for loop to push "registered" words onto a "@regd_wrds" array.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a double-quoted
array of arrays in proper Perl syntax, with each inner array being a sequence of single-quoted words followed by a
registration string, like so:
./ch-1.pl "(['Tom', 'Bob', 'Sue', 'O32 M7T'], ['fig', 'apple', 'peach', 'APE H7C'])"

Output is to STDOUT and will be each word list, followed by the registration string, followed by the list of
"fully-registered" words (words containing all letters from the registration string).

=cut

# ------------------------------------------------------------------------------------------------------------
# PRELIMINARIES:
use v5.36;
use strict;
use warnings;
use utf8;
use Time::HiRes 'time';
use List::Util  'uniq';
$"=', ';

# ------------------------------------------------------------------------------------------------------------
# SUBROUTINES:
sub is_in_list ($item, $list) {
   for (@$list) {$item eq $_ and return 1;}
   return 0;
}

sub is_registered ($wrd, $reg) {
   my @wrdfc = uniq sort split //, fc $wrd =~ s/\PL//gr;
   my @regfc = uniq sort split //, fc $reg =~ s/\PL//gr;
   for (@regfc) {is_in_list($_, \@wrdfc) or return 0;}
   return 1;
}

# ------------------------------------------------------------------------------------------------------------
# DEFAULT INPUTS:
my @arrays =
(
   [ 'abc',   'abcd',  'bcd',   'AB1 2CD' ],
   [ 'job',   'james', 'bjorg', '007 JB'  ],
   [ 'crack', 'road',  'rac',   'C7 RA2'  ],
);

# ------------------------------------------------------------------------------------------------------------
# NON-DEFAULT INPUTS:
if (@ARGV) {@arrays = eval($ARGV[0]);}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
{ # begin main
   my $t0 = time;
   for my $aref (@arrays) {
      my @words = @{$aref};
      my $reg = pop @words;
      my @regd_wrds = ();
      for my $word (@words) {
         if (is_registered($word, $reg)) {
            push @regd_wrds, $word;
         }
      }
      say '';
      say "word list         = (@words)";
      say "registration code = $reg";
      say "registered words  = (@regd_wrds)";
   }
   my $µs = 1000000 * (time - $t0);
   printf("\nExecution time was %.3fµs.\n", $µs);
   exit 0;
} # end main
