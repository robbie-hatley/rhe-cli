#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# 100-Lights.pl
# Solves The 100 Lights Problem.
# Written by Robbie Hatley.
# Edit history:
# Fri Feb 24, 2023: Wrote it.
# Sun Feb 09, 2025: Reduced width from 120 to 110.
##############################################################################################################

use v5.36;
use bigint;
use Time::HiRes 'time';

my $t0 = time;
say "Now entering program \"100-Lights.pl\".";
my $lights = 0; # Bitmap of Lights
my $P         ; # Person Index
my $L         ; # Light  Index
for    ( $P = 1 ; $P <= 100 ; ++$P ){              # For each Person.
   for ( $L = 1 ; $L <= 100 ; ++$L ){              # For each Light.
      if ( 0 == $L % $P ){                         # If Person is to toggle Light
         my $mask = 1 << (100-$L);                 # Lamp position to toggle (Leftmost=1, Rightmost=100)
         $lights ^= $mask;}}}                      # Toggle a Light.
say "Solution to 100 Lights Problem: The following lights remain on";
say "after all 100 persons have tampered with the switches:";
for (1..100){                                      # For each Light
   my $mask = 1 << (100-$_);                       # Lamp position to examine (Leftmost=1, Rightmost=100)
   if ($lights & $mask){                           # If that Light is "on",
      print " ", $_;}}                             # print it's Light number.
print "\n";
my $t1 = time; my $te = $t1 - $t0;
say "Now exiting program \"100-Lights.pl\". Execution time was $te seconds.";
