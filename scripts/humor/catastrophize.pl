#!/usr/bin/env perl
# catastrophize.pl
use v5.16;
my @catastrophies =
(
   "Oh my God!",
   "What the fuck??",
   "This is an utter disaster!!",
   "This is the end of everything!",
   "What am I going to do???",
   "This is the worst thing to ever happen to me!",
   "I might as well end it all!",
   "Oh, God, why was I even born??",
);
sub intervene {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   Now, you wait just a minute! You KNOW that's not actually true!
   There are always other options! Let's just calm down, exit from
   these endless, repetitive, self-validating exaggerations and
   think this through calmly.
   END_OF_HELP
}
sub what;
sub what {
   my $utterance = shift // '';
   if (length $utterance >= 800) {
      return $utterance;
   }
   else {
      $utterance .= ' ' if 0 != length $utterance;
      $utterance .= $catastrophies[int rand scalar @catastrophies];
      say $utterance and intervene     and exit if 19 == int rand 25;
      say $utterance and say "BANG!!!" and exit if 17 == int rand 25;
      return what $utterance;
   }
}
say what;
