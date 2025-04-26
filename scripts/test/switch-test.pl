#!/usr/bin/env perl
# switch-test.pl
use v5.16;
use Switch '__';
exit if 1 != @ARGV;
my $x = $ARGV[0];
say "\nSwitch with no next:\n";
switch ($x) {
   case __ >=  10 {say " 10 <= x < ∞  "}
   case __ >=   5 {say "  5 <= x < 10 "}
   case __ >=   0 {say "  0 <= x < 5  "}
   case __ >=  -5 {say " -5 <= x < 0  "}
   case __ >= -10 {say "-10 <= x < -5 "}
   case __ <  -10 {say " -∞ <  x < -10"}
}
say "\nSwitch with next:\n";
switch ($x) {
   case __ >=  10 {say " 10 <= x < ∞  ";next;}
   case __ >=   5 {say "  5 <= x < 10 ";next;}
   case __ >=   0 {say "  0 <= x < 5  ";next;}
   case __ >=  -5 {say " -5 <= x < 0  ";next;}
   case __ >= -10 {say "-10 <= x < -5 ";next;}
   case __ <  -10 {say " -∞ <  x < -10";next;}
}
