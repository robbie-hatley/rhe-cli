#!/usr/bin/env -S perl -C63

# deg2rad.pl

use v5.16;
use utf8;
use Scalar::Util  qw( looks_like_number );
use Math::Trig    qw(        pi         );

for ( @ARGV ) {
   if ( !looks_like_number($_) ) {
      die "Error: Arguments must be numbers.\n";
   }
}

if ( scalar(@ARGV) > 1 ) {
   warn "Warning: Arguments after 1st will be ignored.\n";
}

my $deg = $ARGV[0] // 0;
my $rad = $deg * pi / 180;
say(qq($rad radians));
