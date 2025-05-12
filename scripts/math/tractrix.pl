#!/usr/bin/env perl
# tractrix.pl
package tractrix {
   use v5.36;
   use Math::Trig;
   sub new {
      my $class = $_[0];
      my $a     = $_[1] // 1;
      my $self  = {a => $a};
      bless $self, $class;
   }
   sub t {
      my $s = shift;
      my $y = shift;
      my $a = $s->{a};
      return $a*asech($y/$a)-sqrt($a*$a-$y*$y);
   }
   sub d {
      my $s = shift;
      my $y = shift;
      my $a = $s->{a};
      my $n = $a*sqrt($a*$a-$y*$y)+($a*$a-$y*$y);
      my $d = $y*sqrt($a*$a-$y*$y)+$a*$y
      return -$n/$d;
   }
   # x = a*ln((a+sqrt(a^2-y^2))/y) - sqrt(a^2-y^)
   # OK, fine, but what is y in terms of x??? THAT is
   # apparently an unsolved problem in mathematics.
   # Oh, it can be "solved" APPROXIMATELY by using
   # either The Bisection Method or
   # The Newton-Raphson Method, but that's an
   # APPROXIMATION, not a SOLUTION. So, how the devil
   # do we INVERT this frickin thing???
   sub i {
      my $s = shift;
      my $y = shift;
      my $a = $s->{a};
      return "There once was a man of aspersion,\n"
            ."who, no many how much coercion,\n"
            ."   he tried and he tried\n"
            ."   but he just couldn't find\n"
            ."the tractrix formula inversion!\n";
   }
}
use v5.36;
use Math::Trig;
my $a = $ARGV[0] // 5.317;
my $o = tractrix->new($a);
for my $i (1..99) {say $o->t(($i/100)*$a)}
