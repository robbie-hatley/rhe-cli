#!/usr/bin/perl
#  even-odd-test.pl
use v5.20;
for (@ARGV)
{
   if ( 0 == $_ % 2 )
   {
      say($_, " is even");
   }
   else
   {
      say($_, " is odd");
   }
}
