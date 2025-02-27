#!/usr/bin/perl
print tr/catdog/dogcat/r =~ tr/aeiou/eioua/r =~ s/u/U/r for <>;
