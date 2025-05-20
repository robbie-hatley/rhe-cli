#!/usr/bin/env perl
# plasmarc-split.pl
use v5.36;
use utf8::all;
open FH, '<', '/home/aragorn/.config/plasmarc';
my @lines = <FH>;
close FH;
my @pics = split ",", $lines[4];
$pics[0] =~ s#^usersWallpapers=##;
for my $pic (@pics) {say $pic}
