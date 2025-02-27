#!/usr/bin/perl
#  /rhe/scripts/test/backquote-test.pl
#A test of `backquotes`.
#This program prints a listing of the current user's home directory.
my $DirList = `ls -l ~`;
print $DirList;
