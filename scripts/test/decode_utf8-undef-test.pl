#!/usr/bin/env -S perl -CSDA
# decode_utf8-undef-test.pl
use v5.32;
use utf8;
use warnings FATAL => 'utf8';
use open ':encoding(utf8)', ':std';
no strict;
no warnings;
use Encode;
use Cwd;

my $result = decode('utf8', undef, Encode::FB_DEFAULT);
if    (! defined $result)      {say "SUCCESS";}
elsif ($result =~ /\x{FFFD}/)  {say "REPLACE";}
else                           {say "FAILURE: $result";}
