#!/usr/bin/env perl
# tractrix.pl
use v5.36;
use utf8::all;

sub tractrix ($a) {
   sub ($x) {$a*log(($a+sqrt($a**2-$x**2))/$x) - sqrt($a**2-$x**2);}
}
my $a = 5.317;
my $tractrix_sub_ref = tractrix($a);
say $tractrix_sub_ref->(1);
say $tractrix_sub_ref->(2);
say $tractrix_sub_ref->(3);
say $tractrix_sub_ref->(4);
