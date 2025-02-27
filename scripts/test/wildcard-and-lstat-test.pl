#!/usr/bin/perl
#  /rhe/scripts/test/wildcard-and-lstat-test.pl
use v5.32;
use strict;
use warnings;
use open qw( :utf8 :std );
use warnings FATAL => "utf8";
use Cwd;
use RH::Dir;
use RH::Util;

my $dirpath  = '.';
my $wildcard = '.* *';

$dirpath  = $ARGV[0] if @ARGV >= 1;
$wildcard = $ARGV[1] if @ARGV >= 2;

my $cards = join ' ', map $dirpath . '/' . $_ , split / /, $wildcard;

foreach (<${cards}>) {
   say '';
   my @stats = lstat $_;
   say 'Name         = ', $_;
   say 'FS dev#      = ', $stats[ 0];
   say 'inode        = ', $stats[ 1];
   say 'mode         = ', $stats[ 2];
   say '# of links   = ', $stats[ 3];
   say 'UID          = ', $stats[ 4];
   say 'GID          = ', $stats[ 5];
   say 'dev ID       = ', $stats[ 6];
   say 'size         = ', $stats[ 7];
   say 'access time  = ', $stats[ 8];
   say 'mod    time  = ', $stats[ 9];
   say 'copy   time  = ', $stats[10];
   say 'block size   = ', $stats[11];
   say 'blocks       = ', $stats[12];
}
