#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# caesar-cipher.pl
# Edit history:
#    Sun Nov 14, 2021: Refreshed colophon, title block, and boilerplate. Added argv() and help() functions.
########################################################################################################################

use v5.32;
use utf8;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

sub argv  () ;
sub error () ;
sub help  () ;

my $N;

{ # begin main
   argv;
   my @upper   = split //,'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
   my @lower   = split //,'abcdefghijklmnopqrstuvwxyz';
   my @strings = <STDIN>;
   say '';
   foreach my $S (@strings)
   {
      foreach my $index (0..((length $S)-1))
      {
         my $ord = ord(substr($S,$index,1));
         if ($ord >= 65 && $ord <= 90)
            {substr($S,$index,1) = $upper[($ord-65+$N)%26];}
         if ($ord >= 97 && $ord <= 122)
            {substr($S,$index,1) = $lower[($ord-97+$N)%26];}
      }
      print $S;
   }
   exit 0;
} # end main

sub argv ()
{
   for (@ARGV)
   {
      if ( '-h' eq $_ || '--help' eq $_ ) {help; exit 777;}
   }
   error and exit 666 if scalar(@ARGV) != 1;
   $N = shift @ARGV;
   error and exit 666 if $N !~ /^-?\d{1,2}$/;
   error and exit 666 if $N < -26 || $N > 26;
   return 1;
} # end sub argv ()

sub error ()
{
   print ((<<'   END_OF_ERROR') =~ s/^   //gmr);
   Error: \"caesar-cipher.pl\" requires exactly 1 command-line argument,
   which must be a positive integer in the closed interval [-26,26].
   This will be used as a "rotate" value for printing a "Caesar Cipher"
   rotation of the input.

   Type \"caesar-cipher.pl -h\" to view help file.
   END_OF_ERROR
   return 1;
} # end sub error

sub help ()
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "caesar-cipher.pl". This program prints a Caesar Cipher rotation
   of its input. (The original input remains unchanged.)

   Command lines:
   caesar-cipher.pl -h | --help       (to print this help and exit)
   caesar-cipher.pl < input-file.txt  (to print a Caesar Cipher rotation of input)

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print this help and exit.

   Description of argument:
   This program requires one mandatory argument, which must be an integer
   in the range [-26, 26]. This will be used as a "rotate" value for printing
   a "Caesar Cipher" rotation of the input. Negative values will perform a left
   rotate and Positive values will perform a right rotate.

   Description of input:
   The input is via STDIN and should be an ASCII or UTF-8 string (or a series of
   such strings) containing English letters (and perhaps some other characters).
   The English letters will be alphabetically "rotated" to different letters and
   the other characters will be passed through unchanged. The input can be typed,
   or fed into this program via redirect or pipe.

   Example using keyboard:

      $ caesar-cipher.pl 17
      Seventeen times she smote her foe with her axe,[Enter]
      but each time he withstood her savage blows.[Enter][Ctrl-D]

      Bnenwcnnw crvnb bqn bvxcn qna oxn frcq qna jgn,
      kdc njlq crvn qn frcqbcxxm qna bjejpn kuxfb.

   Example using file redirect:

      $ caesar-cipher.pl 17 < myfile.txt

   Example using pipe:

      $ echo 'Silently, he walked home.' | caesar-cipher.pl 8

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help ()
