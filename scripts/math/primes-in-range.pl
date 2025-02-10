#!/usr/bin/env perl
@ARGV != 2          and die 'Error: must have two arguments: lower limit and upper limit.';
my $lwr = $ARGV[0];
my $upr = $ARGV[1];
$lwr > $upr         and die 'Error: lower limit must be less-than-or-equal-to upper limit.';
$lwr < 2            and die 'Error: lower limit must be at-least 2.';
$upr > 999999999    and die 'Error: upper limit must be less-than one billion.';
my @primes = (2,3,5,7);
CAND: for ( my $cand = 9 ; $cand <= $upr ; $cand += 2 ) {
   my $limit = int sqrt $cand;
   TEST: for my $test ( @primes ) {
      $test > $limit and last TEST;
      0 == $cand % $test and next CAND;
   }
   push @primes, $cand;
}
my $count = 0;
for (@primes) {
   next if $_ < $lwr;
   last if $_ > $upr;
   printf(" % 10d", $_);
   ++$count;
   0 == $count % 6 and printf("\n");
}
print "\n";
print "Found $count primes in the closed interval [$lwr, $upr].";
