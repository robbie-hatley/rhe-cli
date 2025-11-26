#!/usr/bin/env perl
$_ = 'Sam,Mary,Bob,Ellen';
s/,/\\\\,/g;
print "$_\n";
