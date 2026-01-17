#!/usr/bin/env perl
use v5.36;
use utf8::all;
$/ = "\0\0";
my $fh = undef;
open($fh, '<', '.sha1tree')
or die "Error: No \".sha1tree\" file found.\n$!\n";
while (<$fh>) {
   s/\0\0$//;
   my ($path, $size, $modt, $sha1) = split "\0", $_;
   say '';
   say "PATH = $path";
   say "SIZE = $size";
   say "MODT = $modt";
   say "SHA1 = $sha1";
}
