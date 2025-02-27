#!/usr/bin/perl
#This is a comment.
use v5.32;
use strict;
use warnings;

LOOP: {
   state $Variable = 0;
   ++$Variable;
   say $Variable;
   next LOOP if ($Variable >= 10);
   last LOOP;
}
