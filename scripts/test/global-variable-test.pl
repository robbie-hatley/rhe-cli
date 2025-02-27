#!/usr/bin/perl
use v5.32;
use strict;

package main;

$main::Cat;
$::Dog            = "Barney";
$main::Dog        = "Fred";
$main::main::Dog  = "Ethel";

package Egg;

$Egg::Dog         = "Sue";

sub Gargoyle
{
   my $Dog = "Peter";
   print ('$main:Cat              = ', $main::Cat,"\n");
   print ('$::Dog                 = ', $::Dog,"\n");
   print ('$main::Dog             = ', $main::Dog,"\n");
   print ('$main::main::Dog       = ', $main::main::Dog,"\n");
   print ('$Egg::Dog              = ', $Egg::Dog,"\n");
   print ('$Dog                   = ', $Dog,"\n");
   print ('$main::Dog + $Egg::Dog = ', $main::Dog + $Egg::Dog,"\n");
   print ('$main::Cat + $Egg::Dog = ', $main::Cat + $Egg::Dog,"\n");
}

package main;

&Egg::Gargoyle;
