#!/usr/bin/perl

##################################################################
# size-test.pl
# Tests for differences (if any) between -s size and stat size.
##################################################################

use v5.32;
use common::sense;
use Sys::Binmode;

use Cwd;

use RH::Dir;

my $CurDir;
my %CurDirFiles;

$CurDir = cwd_utf8;
print "CWD = ", $CurDir, "\n";

my $dh = undef;
opendir($dh, e $CurDir) or die "Can\'t open directory \"$CurDir\".\n$!\n";
my @files = map {d($_)} readdir($dh);
closedir($dh);

foreach my $file_name (@files)
{
   next if not -e e $file_name;
   my @stats = lstat e $file_name;
   next if not -f _ ;
   my $dash_size = -s _ ;
   my $stat_size = $stats[7];
   printf("%-60s%12s%12s\n", $file_name, $dash_size, $stat_size);

};
# Note, 2014-12-05: On running this script on several directories,
# I find that there is no difference between $dash_size and $stat_size.
# The two numbers are always exactly the same. So, I prefer $dash_size
# for cases in which doing a full "stat" is not necessary, and
# $stat_size for cases in which I'm going to do a stat anyway.
