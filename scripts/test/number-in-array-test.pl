#!/usr/bin/perl
# number-in-array-test.pl

use v5.36;

my @array=(-17, -4, 13, 67, 84);
my $number;

sub in_array ($num, @arr)
{
   for (@arr) {return 1 if $_ == $num;}
   return 0;
}

while (42)
{
   say "Enter an integer (or enter 777 to exit):";
   $number = <STDIN>;
   if ($number !~ m/(?:^0$)|(?:^-?[1-9]\d*$)/)
      {say "That's not a integer!"; next;}
   exit if 777 == $number;
   if (in_array($number, @array))
      {say "number IS in array";}
   else
      {say "number ISN'T in array";}
}
