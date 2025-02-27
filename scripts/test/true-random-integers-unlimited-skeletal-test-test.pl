#!/usr/bin/perl
# true-random-integers-unlimited-skeletal-test.pl
use v5.32;
use bignum;
Math::BigFloat->accuracy(250);

my $N = 25 ;                           # Number of numbers
my $A = Math::BigInt->new(0);          # Begin range
my $B = Math::BigInt->new(10**50 - 1); # End   range

sub print_rand_ints ()
{
   my ($i, $j, $rand344, $randfloat, $scale, $scaledfloat, $scaledint,
       @ordinals, $ord, $bytes, @bytes, $fh);
   open($fh, '< :raw', '/dev/random')
   or die "Can't open \"/dev/random\".\n$!.\n";
   for ( $i = 0 ; $i < $N ; ++$i )
   {
      read($fh, $bytes, 43);
      @bytes = split //,$bytes;
      @ordinals = map {0+ord($_)} @bytes;
      $rand344 = Math::BigInt->new(0);
      for ( $j = 0 ; $j < 43 ; ++$j )
      {
         $rand344 += ($ordinals[$j] << (8*(42-$j)));
      }
      $randfloat   = Math::BigFloat->new($rand344);
      $scaledfloat = $A + (($B+1)-$A)*($randfloat/2**344);
      $scaledint   = Math::BigInt->new(int($scaledfloat));
      printf("%52s\n", $scaledint);
   }
   close($fh);
   return 1;
} # end sub print_rand_ints ()

print_rand_ints();
exit 0;
