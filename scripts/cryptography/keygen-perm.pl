#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# keygen-perm.pl
# Prints the first $ARGV[0] positive integers in random order,
# separated by commas.
# See the print_help_msg subroutine for description and instructions.
# Edit history:
#    Sun Mar 30, 2008: Wrote it.
#    Fri Jul 17, 2015: Minor cleanup (comments, etc).
#    Wed Jan 10, 2018: Improved comments and pod, and fixed fencepost
#                      error (was using 1-indexing instead of 0).
#    Sat May 19, 2018: use v5.20, dramatically improved instructions, and
#                      moved instructions to print_help_msg().
#    Tue Sep 08, 2020: use v5.30
########################################################################################################################

use v5.32;
use utf8;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

sub error_msg;
sub help_msg;

{ # begin main
   if (1 == scalar(@ARGV) && ("-h" eq $ARGV[0] || "--help" eq $ARGV[0]))
   {
      help_msg;
      exit 777;
   }
   if (1 != scalar(@ARGV) || $ARGV[0] < 10 || $ARGV[0] > 2000000000)
   {
      error_msg;
      help_msg;
      exit 666;
   }
   my @Numset = (0 .. $ARGV[0] - 1);
   my @Permutation;
   while (@Numset)
   {
      push @Permutation, splice @Numset, int rand @Numset, 1;
   }
   say join ',', @Permutation;
   exit 0;
} # end main

sub error_msg
{
   print ((<<'   END_OF_ERROR') =~ s/^   //gmr);
   Error: This program takes exactly one argument, which must be
   an integer in the 10 to 2000000000 range.
   END_OF_ERROR
   return 1;
}

sub help_msg
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "keygen-perm.pl", Robbie Hatley's nifty random-permutation
   generator. For any given positive integer n in the range
   [10,2000000000], this program prints the first n non-negative integers to
   stdout, in random order, separated by commas.

   The number n is given by the first argument ($ARGV[0]). If the number of
   arguments is not exactly 1, or if the argument is not a positive integer
   in the range [10,2000000000], this program will abort.

   Usage:
   rand-keygen.pl n
   (Prints the first n non-negative integers in random order, separated by
   commas.)

   Example:
   %rand-keygen.pl 10
   0,9,3,8,7,6,4,1,5,2
   %

   The purpose of this program is to create keys for my rot48 and rot128
   cryptography programs, but it can also be used anytime you need a random
   permutation of the first n non-negative integers, separated by commas,
   printed to stdout.

   Is this version of keygen safer than my "keygen-rand" program? I'm not sure.
   On the one hand, it prevents any line of the pad from being used more than
   once. But on the other hand, if an interloper were to realize that the key
   is a permutation, he could attempt all possible permutations of (0..n),
   which is a lot less than all possible sequences of n numbers from (0..n).
   So I'm not sure, but I'm leaning twoards "keygen-rand" as being safer.

   Happy random permutation generating!

   Cheers,
   Robbie Hatley,
   Programmer
   END_OF_HELP
   return 1;
}
