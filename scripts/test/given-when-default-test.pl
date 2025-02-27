#!/usr/bin/perl
# given-when-default-test.pl
use v5.36;
use experimental "switch";
$_ = "he tapped with his whip on the shutters";
say "global dollscor = $_";
while (<>)
{
   chomp;
   say "local dollscor = $_";
   given ( $_ . $_ )
   {
      say "localer dollscor = $_";
      when (/(?i:cat)/) {say "cat";}
      when (/(?i:dog)/) {say "dog";}
      default {say "unknown animal";}
   }
   say "local dollscor after given = $_";
}
say "global dollscor after while = $_";

