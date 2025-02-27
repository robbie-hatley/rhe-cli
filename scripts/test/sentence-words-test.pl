#!/usr/bin/perl
use v5.36;
$"=', ';
my @list =
(
   "Perl and Raku belong to the same family.",
   "I love Perl.",
   "The Perl and Raku Conference.",
);
for my $sentence (@list) {
   say '';
   say "Sentence = \"$sentence\"";
   my @words = split /[ .]+/, $sentence;
   say "Words = (@words)";
}
