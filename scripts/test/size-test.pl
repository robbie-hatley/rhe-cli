#!/usr/bin/perl
##################################################################
# size-test.pl
# Tests for differences (if any) between -s size and stat size.
##################################################################
use v5.16;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;
use utf8::all;
use Cwd::utf8;

my $curdir = cwd;
say "CWD = \"$curdir\".";

my $dh = undef;
opendir $dh, $curdir                      or die "Can't open  directory \"$curdir\".\n";
my @files = sort {$a cmp $b} readdir $dh  or die "Can't read  directory \"$curdir\".\n";
closedir $dh                              or die "Can't close directory \"$curdir\".\n";

foreach my $name (@files) {
   next if not -e $name;
   my @stats = lstat $name;
   next if not -f _ ;
   my $dash_size = -s _ ;
   my $stat_size = $stats[7];
   printf("%-60s  d-size = %10d  s-size = %10d\n", $name, $dash_size, $stat_size);

};
# Note, 2014-12-05: On running this script on several directories,
# I find that there is no difference between $dash_size and $stat_size.
# The two numbers are always exactly the same. So, I prefer $dash_size
# for cases in which doing a full "stat" is not necessary, and
# $stat_size for cases in which I'm going to do a stat anyway.
