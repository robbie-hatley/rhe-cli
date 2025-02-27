#!/usr/bin/perl
# temp-check.pl
use v5.32;
exit if 1 != @ARGV;
if ($ARGV[0] <= 18.5)
{
   say 'Too cold!';
}
elsif ($ARGV[0] >= 78.5)
{
   say 'Too hot!';
}
else
{
   say 'Just right!';
}
