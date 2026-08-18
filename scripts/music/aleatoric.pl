#!/usr/bin/env perl

# Created needed variables:
my @pits; # Pitches.
my @durs; # Durations.
my $p;    # A pitch.
my $d;    # A duration.

# Create 8 octaves of 12-TET pitches from C0 through C8:
for (0..96) {
   push @pits, 16.35160*2.0**($_/12);
}

# Create a 4/4 moderato 8-bar sequence of durations:
@durs =
(
   2,     2,     2,     3,3,
   3,3,   3,3,   2,     2,
   2,     2,     2,     3,3,
   2,     2,     1,
   3,3,   3,3,   2,     2,
   3,3,   3,3,   2,     2,
   2,     3,3,   3,4,4, 3,3,
   2,     2,     1,
);

# Get size of @pits:
my $np = scalar(@pits);

# Let aleatoric music commence, to ∞ and beyond!
while (1) {
   # Play an 8-bar phrase:
   for my $dur (@durs) {
      $p = $pits[int(rand()*($np))]; # Random pitch.
      $d = 1600/2**$dur;             # Non-random duration.
      system("abeep -f $p -l $d");   # Make sound.
   }
}
