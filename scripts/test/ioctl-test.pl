#!/usr/bin/env perl
# ioctl-test.pl
use v5.40;
require "sys/ioctl.ph";
# four unsigned shorts of the native size
my $template = "S!4";
# pre–allocate the right size buffer:
my $ws = pack($template, ());
ioctl(STDOUT, TIOCGWINSZ(), $ws)
|| die "Couldn't call ioctl: $!";
my ($rows, $cols, $xpix, $ypix) = unpack($template, $ws);
say "rows = $rows";
say "cols = $cols";
say "xpix = $xpix";
say "ypix = $ypix";
