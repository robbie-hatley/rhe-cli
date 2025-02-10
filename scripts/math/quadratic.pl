#!/usr/bin/env perl
##############################################################################################################
# quadratic.pl
# Calculates quadratic functions.
# Edit history:
#    Sun Jan 31, 2021: Wrote it.
##############################################################################################################
use v5.36;
exit 666 if 3 != scalar(@ARGV);
sub Quad ($a,$b,$c) {
   return sub ($x) {$a*$x*$x + $b*$x + $c}
}
my $f = Quad(@ARGV);
my ($x, $y);
for ( $x = -5.0 ; $x < 5.001 ; $x += 0.1 )
{
   $y = &$f($x);
   printf("f(%7.4f) = %10.4f\n", $x, $y);
}
