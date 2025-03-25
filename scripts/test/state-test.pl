#!/usr/bin/env -S perl -C63
# state-test.pl
# Pragmas:
use v5.36;
use utf8;
sub asdf {
   state $Fred = 0;
   say "on entry, Fred is $Fred";
   ++$Fred;
}
asdf;
asdf;
asdf;
