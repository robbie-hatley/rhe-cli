#!/usr/bin/env perl
# plasmarc-join.pl
use v5.36;
use utf8::all;
my @lines = ('[Theme]','name=default','','[Wallpapers]','usersWallpapers=');
my @pics = map {chomp;$_} <>;
$lines[4] .= join(',', @pics);
open FH, '>', '/home/aragorn/.config/plasmarc';
for my $line (@lines) {say FH $line}
close FH;
