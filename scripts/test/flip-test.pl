#!/usr/bin/perl
use v5.32;
use strict;
use warnings;

`cd '/cygdrive/c/E/RHE/scripts/test'`;

say(' ');
say('DOUBLE DOT 6 10:');
say(' ');

open(ARGLE, '<', "text15.txt");
while (<ARGLE>) {
   chomp;
   my $result = scalar(6..10);
   print("line# = $.  ");
   if ($result) {print("true   $result\n");}
   else         {print("false\n");}
}
close ARGLE;

say(' ');
say('TRIPLE DOT 6 10:');
say(' ');

open(ARGLE, '<', "text15.txt");
while (<ARGLE>) {
   chomp;
   my $result = scalar(6...10);
   print("line# = $.  ");
   if ($result) {print("true   $result\n");}
   else         {print("false\n");}
}
close ARGLE;

say(' ');
say('DOUBLE DOT 6 6:');
say(' ');

open(ARGLE, '<', "text15.txt");
while (<ARGLE>) {
   chomp;
   my $result = scalar(6..6);
   print("line# = $.  ");
   if ($result) {print("true   $result\n");}
   else         {print("false\n");}
}
close ARGLE;

say(' ');
say('TRIPLE DOT 6 6:');
say(' ');

open(ARGLE, '<', "text15.txt");
while (<ARGLE>) {
   chomp;
   my $result = scalar(6...6);
   print("line# = $.  ");
   if ($result) {print("true   $result\n");}
   else         {print("false\n");}
}
close ARGLE;
