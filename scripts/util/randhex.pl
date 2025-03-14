#!/usr/bin/env perl
# randhex.pl
# Generates 1-to-1,000,000 random bytes and prints them to STDOUT,
# after setting STDOUT's binmode to ":raw". Written at an unknown
# date by Robbie Hatley.
use v5.36;
use strict; use warnings; no warnings 'numeric';
binmode STDIN,  'utf8';
binmode STDOUT, ':raw';
binmode STDERR, 'utf8';
my $size = 100;
if ( @ARGV && 0+$ARGV[0] >= 1 && 0+$ARGV[0] <=1000000 ) {$size = $ARGV[0]}
my $buffer;
srand;
for ( my $i = 0 ; $i < $size ; ++$i ) {
   my $rand = int(rand()*256);
   my $byte = chr($rand);
   $buffer .= $byte;
}
print STDOUT $buffer;
