#!/usr/bin/perl
use Compress::Deflate7 'deflate7';
my $text = "She sells sea shells.";
my $rfc1951 = deflate7("...");
say $rfc1951;
