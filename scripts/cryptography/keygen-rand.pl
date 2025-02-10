#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# keygen-rand.pl
# Prints ARGV[0] random integers from the closed-open interval [0,ARGV[1]),
# separated by commas.
# See the print_help_msg subroutine for description and instructions.
# Edit history:
#    Tue Jul 14, 2015: Wrote first draft.
#    Fri Jul 17, 2015: Simplified, and wrote comments.
#    Wed Jan 10, 2017: use v5.026; improved comments; added help; added POD.
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

sub print_error_msg;
sub print_help_msg;

{ # begin main
   if (1 == scalar(@ARGV) && ("-h" eq $ARGV[0] || "--help" eq $ARGV[0]))
   {
      print_help_msg;
      exit 777;
   }
   if (2 != scalar(@ARGV) || $ARGV[0] < 10 || $ARGV[0] > 2000000000
                          || $ARGV[1] < 10 || $ARGV[1] > 2000000000)
   {
      print_error_msg;
      print_help_msg;
      exit 666;
   }
   my @RandomNumbers;
   for (1..$ARGV[0])
   {
      push @RandomNumbers, int rand $ARGV[1];
   }
   say join ',', @RandomNumbers;
   exit 0;
} # end main

sub print_error_msg
{
   print ((<<'   END_OF_ERROR') =~ s/^   //gmr);
   Error: This program takes exactly two arguments, which must be
   integers in the 10 to 2000000000 range.
   END_OF_ERROR
   return 1;
}

sub print_help_msg
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "keygen-rand.pl", Robbie Hatley's nifty random non-negative
   integer generator. This program writes m random non-negative integers from
   the range [0,n) (where m and n are integers in the range
   [10,2000000000]) to stdout, separated by commas.

   The number m is given by the first  argument, $ARGV[0].
   The number n is given by the second argument, $ARGV[1].
   If the number of arguments is not exactly 2, or if either argument is not
   a positive integer in the range [10,2000000000], this program will abort.

   Usage:
   keygen-rand.pl n m
   (Prints a string of n random integers less than m, separated by commas.)

   Example:
   %keygen-rand.pl 10 10
   0,9,3,9,4,7,2,3,8,
   %

   The purpose of this program is to create keys for my rot48 and rot128
   cryptography programs, but it can also be used anytime you need m random
   non-negative integers less than n, separated by commas, printed to stdout.

   Note that it is NOT guaranteed that there will be no duplicates.
   Also note that if n>m, it IS guaranteed that there WILL BE duplicates.

   If no duplication is desired, use program "perm-keygen.pl" instead,
   which prints all of the non-negative integers less than m, each exactly
   one time, in random order, separated by ", ". In other words, it prints
   a random permutation of the set {x|0<=x<m} where x is "any integer" and
   m is a specific integer in the 10-10000 range.

   This program has both advantages and disadvantages over my "keygen-perm.pl"
   program.

   On the plus side, it allows for messages to be larger than pads. For example,
   you could use a 1000-number key and a 100-row pad to encrypt/decrypt messages
   up to 1000 characters.

   On the minus side, using messages bigger than pads decreases security, and
   allowing duplication (same pad row used for multiple characters) also decreases
   security.

   Happy random non-negative-integer generating!

   Cheers,
   Robbie Hatley,
   Programmer
   END_OF_HELP
   return 1;
}
