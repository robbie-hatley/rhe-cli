#!/usr/bin/perl
# for-and-last-test.pl
use v5.36;
while (<>)
{
   for($_)
   {
      /(?i:cat)/ and say "cat" and last;
      /(?i:dog)/ and say "dog" and last;
      say "unknown animal";
   }
}
