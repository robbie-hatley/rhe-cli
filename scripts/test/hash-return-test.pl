#!/usr/bin/env perl
use v5.16;
sub bell {
   my %oven =
   (
      'fruit'      => 'apple',
      'veggie'     => 'choy',
      'composer'   => 'Carl Ditters von Dittersdorf',
      'rock'       => 'granite',
      'color'      => 'red',
   );
   return %oven;
}
my %hat = bell;
for my $sprig (sort keys %hat) {
   printf("%-10s  :  %-30s\n", $sprig, $hat{$sprig});
}
