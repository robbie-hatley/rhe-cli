#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# "gen-colors.pl"
# Generates color table and prints it to file "mandelbrot.ini"
# in directory ~/bin/fractals .
# Edit history:
#    Wed May 18, 2016:
#       Wrote it.
########################################################################################################################

use v5.32;
use utf8;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

my @colors;
my $r; my $g; my $b;

for ( my $i = 0 ; $i < 256 ; ++$i )
{
   if ( $i >= 0 && $i < 51 ) # black -> red
   {
      $r = int(( $i -   0) / 51 * 255 + 0.000001);
      $g = 0x00;
      $b = 0x00;
   }
   elsif ( $i >= 51 && $i < 102 ) # red -> green
   {
      $r = int((102 -  $i) / 51 * 255 + 0.000001);
      $g = int(( $i -  51) / 51 * 255 + 0.000001);
      $b = 0x00;
   }
   elsif ( $i >= 102 && $i < 153 ) # green -> blue
   {
      $r = 0x00;
      $g = int((153 -  $i) / 51 * 255 + 0.000001);
      $b = int(( $i - 102) / 51 * 255 + 0.000001);
   }
   elsif ( $i >= 153 && $i < 204 ) # blue -> violet
   {
      $r = int(( $i - 153) / 51 * 255 + 0.000001);
      $g = 0x00;
      $b = 0xFF;
   }
   elsif ( $i >= 204 && $i <= 255 ) # violet -> white
   {
      $r = 0xFF;
      $g = int(( $i - 204) / 51 * 255 + 0.000001);
      $b = 0xFF;
   }
   push @colors, [$r,$g,$b];
}

chdir_utf8 '/rhe/bin64/fractals'
or die "Couldn't cd to fractals folder.\n$!\n";

my $fh;
open_utf8($fh, '>', 'mandelbrot.ini') or die "Can't open mandelbrot.ini for writing.\n$!\n";
for (reverse @colors) {printf($fh "%02X %02X %02X\n", @{$_});}
close $fh;
exit 0;

=pod

0  1  2  3  4  5

Red:
  /\       /‾‾‾
 /  \     /
/    \___/


Green:
     /\       /
    /  \     /
___/    \___/


Blue:
        /‾‾‾‾‾‾
       /
______/


=cut

