#!/usr/bin/perl
#  /rhe/scripts/test/sharma-zero-one-V2.pl
use v5.32;
use strict;
use warnings;
my $string = $ARGV[0] // die "[ERROR] Insufficient arguments";
my @m = (0) x 4; # holds the max counts
1 while $string =~ m{
   (?:
      (?: # run of 1s/0s
         (?{ local $a = 1 })             # init kount for length run of 1s/0s
         (?:(0)|(1))(?>(?(1)0|1)(?{ $a++ }))*  # compute length of 1s/0s
         (?{                                   # compute max of run of 1s/0s
            local *b = \$m[$1//$2];
            $a > $b and $b = $a;
            $b > $m[2] and $m[2] = $b;
         })
      ) |
      (?: # run of others
         (?{ local $a = 1 })         # init kount for length of run of others
         (?:[^01])(?>[^01](?{ $a++ }))*    # compute length of run of others
         (?{ $a > $m[3] and $m[3] = $a })  # compute max of run of others
      )
   )
   (?{ $m[4] = ($m[3] > $m[2]) ? $m[3] : $m[2] }) # compute the overall max
}xg;
say $string;
say "max 0s run=",       $m[0];
say "max 1s run=",       $m[1];
say "max of 0s/1s run=", $m[2];
say "max others run=",   $m[3];
say "max overall=",      $m[4];
