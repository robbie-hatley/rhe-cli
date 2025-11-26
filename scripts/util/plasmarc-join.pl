#!/usr/bin/env perl
# plasmarc-join.pl
use v5.36;
use utf8::all;
my $user  = getlogin;
my @lines = ('[Wallpapers]','usersWallpapers=');
my @pics  = map {s/^\N{BOM}//;s/^\s+//;s/\s+$//;s/,/\\\\,/g;$_} <>;
$lines[1] .= join(',', @pics);
open FH, '>', "/home/$user/.config/plasmarc" or die "Couldn't open plasmarc for writing!\n";
for my $line (@lines) {say FH $line}
close FH;
