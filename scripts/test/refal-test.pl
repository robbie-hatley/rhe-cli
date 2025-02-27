#!/usr/bin/perl
# refal-test.pl
use v5.32;
use feature 'refaliasing';
no warnings 'experimental::refaliasing';
(my $tom, \my $dick, \my @harry) = (\1, \2, [11..93]);
say "\$\$tom = $$tom";
say "\$tom = $tom";
say "\$dick = $dick";
#$$tom = 77; # "read only" error
#$dick = 88; # "read only" error
say "\$harry[21] = $harry[21]";
$harry[21] = 897; # This works! Why?
say "\$harry[21] = $harry[21]";
