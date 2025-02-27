#!/usr/bin/perl
#  /rhe/scripts/test/capture-test.pl
use v5.32;
use strict;
use warnings;

our $text = 'pounding stridently on a xyzlophone';
our $regex;
our @matches;

$regex = '(st)..(de)..(ly)';
say '';
say "Text  = \"$text\"";
say "Regex = \"$regex\"";
say((@matches = $text =~ m/$regex/) ? "Matches." : "Does not match.");
if ($1) {
   say("Number of captures = ", scalar(@matches));
   say("Captures = \"", join('", "', @matches), "\"");
   say ( defined $1 ? "\$1 = \"$1\"" : "\$1 = undef" );
}
else {
   say('No captures.');
   say("\$1 = $1");
}

$regex = 'phon';
say '';
say "Text  = \"$text\"";
say "Regex = \"$regex\"";
say((@matches = $text =~ m/$regex/) ? "Matches." : "Does not match.");
if ($1) {
   say("Number of captures = ", scalar(@matches));
   say("Captures = \"", join('", "', @matches), "\"");
   say("\$1 = $1");
}
else {
   say('No captures.');
   say ( defined $1 ? "\$1 = \"$1\"" : "\$1 = undef" );
}
