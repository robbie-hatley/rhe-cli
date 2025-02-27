#!/usr/bin/perl
use strict;
use warnings;
my $result;
my $code = q{$result = 17.3 / $val};
for my $val (7.4, 3.9, 0)
{
   print "\n";
   $@ = "XXXX";
   eval "$code";
   print "\$code = $code\n";
   print "\$result = $result\n";
   print "\$@ = $@\n";
}
