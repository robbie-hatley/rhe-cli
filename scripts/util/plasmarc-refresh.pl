#!/usr/bin/env perl
# plasmarc-refresh.pl
use v5.42;
use utf8::all;
chdir '/d/OS-Resources/Background-Pictures';
system 'list-paths.pl -fqr | extract-image-paths.pl | plasmarc-join.pl';
