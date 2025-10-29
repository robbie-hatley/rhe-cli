#!/usr/bin/env -S perl -C63

# dms2deg.pl

use v5.16;
use utf8;
use Scalar::Util  qw( looks_like_number );
use Math::Trig    qw(        pi         );

sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);
   All arguments must be real numbers.
   0th arg must be in the -180 to +180 range.
   nth arg must be in the  -60 to  +60 range.
   0th argument will be construed as degrees.
   nth argument will be construed as degrees*arg/60**n.
   Hence, given 3 arguments, they will be degrees, minutes, seconds.
   For north lat or east long, all arguments must be positive.
   For south lat or west long, all arguments must be negative.
   END_OF_HELP
   return 1;
}

# If user asked for help, give help and exit:
for ( @ARGV ) {
   if ( '-h' eq $_ || '--help' eq $_ ) {
      help;
      exit 777;
   }
}

# If user did NOT ask for help, all arguments must be within range:
for my $i (0..$#ARGV) {
   if (
         !looks_like_number($ARGV[$i])
      || $i == 0 && ($ARGV[$i] < -180 || $ARGV[$i] > +180)
      || $i  > 0 && ($ARGV[$i] <  -60 || $ARGV[$i] >  +60)
   ) {
      warn "Error: Argument out-of-range.\n";
      help;
      exit 666;
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
say(qq($degrees°));
