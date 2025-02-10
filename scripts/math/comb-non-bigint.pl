#!/usr/bin/env perl

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

################################################################
# "comb-non-bigint.pl"
# Prints number of combinations of n things taken k at a time.
# Edit history:
#    Sun Feb 28, 2016 - Wrote it.
################################################################

use v5.32;

sub fact ($)
{
   my $x = shift;
   my $fact = 1;
   $fact *= $_ for (2..$x);
   return $fact;
}

sub comb ($$)
{
   my $n = shift;
   my $k = shift;
   my $comb = fact($n)/fact($n-$k)/fact($k);
   return $comb;
}

# main
{
   my $n = $ARGV[0];
   my $k = $ARGV[1];
   my $nok = comb($n, $k);
   say "$n comb $k = $nok";
   exit 0;
}
