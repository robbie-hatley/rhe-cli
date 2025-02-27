#!/usr/bin/perl
# weird-recursion-test.pl
use v5.32;
sub f
{
   my $n = shift;
   if ($n <= 2)
   {
      f($n+1);
      f($n+1);
      say $n;
   }
}

f($_) for @ARGV;
