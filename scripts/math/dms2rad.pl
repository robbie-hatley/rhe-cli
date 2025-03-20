#!/usr/bin/env -S perl -C63

# dms2rad.pl

use v5.16;
use utf8;
use Scalar::Util  qw( looks_like_number );
use Math::Trig    qw(        pi         );

for ( @ARGV ) {
   if ( !looks_like_number($_) ) {
      die "Error: Arguments must be numbers.\n";
   }
}

if ( scalar(@ARGV) > 9 ) {
   warn "Warning: Arguments after 9th will have no effect.\n";
}

# We can divide a degree into sixtieths as many times as we want:
# 1 minute  = 1/60 degree
# 1 second  = 1/60 minute
# 1 argblu  = 1/60 second
# 1 senska  = 1/60 argblu
# Etc, etc, etc. Sexagesimal is fun! :-)

my $degrees = 0;
for ( my $i = 0 ; $i <= $#ARGV ; ++$i ) {
   $degrees += $ARGV[$i]/60**$i;
}
my $radians = $degrees * pi / 180;
say(qq($radians radians));
