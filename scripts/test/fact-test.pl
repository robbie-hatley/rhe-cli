#!/usr/bin/perl
use v5.36;
use bignum;
use RH::Math 'fact';
for ( my $f, my $i = 0 ; $i <= 100 ; ++$i ) {
   $f = fact($i);
   say "$i! = $f";
}
