#!/usr/bin/env perl
use v5.42;
use feature 'bareword_filehandles';
no strict 'subs';

# scalar slot:
*FCN::PI = \3.14159;

# code slot:
*FCN::PI = sub {return 3.14158};

# array slot:
*FCN::PI = [3.14157];

# hash slot:
*FCN::PI = {lowval => 3.14156};

# io slot:
my $buf = "3.14155\n";
open FCN::PI, "<", \$buf or die "open failed\n";

# format slot:

format FCN::PI =
format = @<<<<<<
3.14154
.

say "scalar = ", $FCN::PI;
say "code   = ", &FCN::PI;
say "array  = ", @FCN::PI;
say "hash   = ", $FCN::PI{lowval};
say "io     = ", (scalar <FCN::PI>) =~ s/\n$//r;
local $~ = FCN::PI;write;
