#!/usr/bin/env -S perl -C63
# readdir-regexp-utf8-test.pl
use v5.36;
use utf8;
use RH::Dir;
use Cwd;
my $direct = $ARGV[0] // d(getcwd);
my $target = $ARGV[1] // 'A';
my $regexp = $ARGV[2] // qr(^.+$)o;
my $predic = $ARGV[3] // 1;
my @names = readdir_regexp_utf8($direct, $target, $regexp, $predic);
say for @names;
