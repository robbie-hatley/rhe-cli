#!/usr/bin/perl
#  /rhe/scripts/test/line-end-adjust-test.pl
use v5.32;
use strict;
use warnings;
my $var  = "Unfortunately, she forgot to pack tootpaste.\x0d";
   $var .= "But there did turn out to be a store on the corner.\x0a";
   $var .= "So that problem was solved rather easily.\x0a\x0a";
   $var .= "However, not so with the issue regarding the dog.\x0d\x0d";
   $var .= "She forgot to leave it ample water.\x0d\x0a";
   $var .= "So while there was plenty of food for it to eat,\x0a\x0d";
   $var .= "it none the less was very thirsty\x0d\x0d\x0a\x0a";
   $var .= "by the time she got home from the trip.\x0d\x0a\x0a\x0d";

$var =~ s/(?:\x0d|\x0a)+/\x0d/g;
print $var;
