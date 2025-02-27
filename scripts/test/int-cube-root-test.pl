#!/usr/bin/perl
use v5.38;
sub int_cube_root ($x) {
   my $r = 0;
   if ($x < 0) {--$r until ($r-1)*($r-1)*($r-1) < $x}
   else        {++$r until ($r+1)*($r+1)*($r+1) > $x}
   return $r;
}
say int_cube_root($ARGV[0]);
