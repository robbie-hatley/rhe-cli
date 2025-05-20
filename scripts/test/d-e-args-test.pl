#!/usr/bin/env -S perl -C63
# d-e-args-test.pl
use v5.36;
use utf8;
use Cwd;
use RH::Dir;
my $cwd = d(cwd);
my $dh = undef;
opendir $dh, e $cwd;
while (my $f = d readdir $dh) {say $f}
closedir $dh;
say '';
opendir $dh, $cwd;
while (readdir $dh) {say d $_}
closedir $dh;
