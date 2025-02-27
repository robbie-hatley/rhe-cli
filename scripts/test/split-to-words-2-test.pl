#!/usr/bin/perl
# split-to-words-test2.pl
use v5.32;
my @Words;
while (<>)
{
   s/[\x0a\x0d]+$//;
   push @Words, split '[ \t,.?!\"]+';
}
say for @Words;
