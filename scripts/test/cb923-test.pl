#!/usr/bin/env -S perl -CSDA
# cb923-test.pl
use v5.36;
use strict;
use warnings;
my $path = <~>;
opendir(THATDIR, $path) || die "can't opendir $path : $!";
my @dotfilenames = sort grep {-f} map {"$path/$_"} grep {/^\./} readdir(THATDIR);
closedir THATDIR;
say for @dotfilenames;
