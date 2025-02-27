#!/usr/bin/perl
# encoded-regex-test.pl
use v5.32;
use utf8;
use Encode;

my $encoded_regex = encode_utf8 '山梨県';
while (<*>)
{
   #say if /$encoded_regex/;
   say if /、\p{Lo}+、/;
}
