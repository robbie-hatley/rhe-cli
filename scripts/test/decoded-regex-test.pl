#!/usr/bin/env -S perl -CSDA
# decoded-regex-test.pl
use v5.32;
use utf8;
use Encode;
my $decoded;
while (<*>)
{
   $decoded = decode_utf8 $_ ;
   say($decoded) if $decoded =~ m/、\p{Lo}{4}、/;
}
