#!/usr/bin/perl
# random-shift-test.pl
use v5.32;
use bignum;
Math::BigFloat->accuracy(250);
my  ($fh, $i, $bytes, @bytes, @ordinals, $ord, $rand336, $randfloat, $randshift, $randmant);
open($fh, '< :raw', '/dev/random')
or die "Can't open \"/dev/random\".\n$!.\n";
read($fh, $bytes, 42);
close($fh);
@bytes = split //,$bytes;
@ordinals = map {0+ord($_)} @bytes;
for my $ord (@ordinals) {printf("%02s", ($ord)->to_hex);} printf(" (ords)\n");
for ( $i = 0 ; $i < 42 ; ++$i )
{
   $rand336 += ($ordinals[$i] << (8*(41-$i)));
}
printf("%084s (rand336)\n", $rand336->to_hex);
printf("%s (decimal)\n", $rand336);
say '';
for (1..35)
{
   $randfloat = Math::BigFloat->new(rand);
   $randmant  = $randfloat->mantissa;
   printf("\$randmant = %s\n", $randmant);
}
