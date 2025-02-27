#!/usr/bin/env -S perl -CSDA
# file-glob-test-1.pl

use v5.32;
use strict;
use warnings;
use utf8;

use Encode;
use Cwd;

our $curdirhandle;
our $curdir;
our @files;

$curdir = getcwd;

say 'List #1, opendir/readdir/closedir:';
opendir($curdirhandle, $curdir) or die "Can\'t open directory $curdir\n$!\n";
@files = map {decode_utf8 $_} readdir($curdirhandle);
closedir($curdirhandle);
foreach my $file (@files)
{
   say $file;
   if ($file =~ m/Cô-Chạy-Xuống-달렸-富士川町/) {say 'Matches!';}
}

say '';
say '';

say 'List #2, <.* *>:';
@files = map {decode_utf8 $_} <.* *>  or die "Can\'t glob directory $curdir\n$!\n";
foreach my $file (@files)
{
   say $file;
   if ($file =~ m/Cô-Chạy-Xuống-달렸-富士川町/) {say 'Matches!';}
}

say 'Length of Cô-Chạy-Xuống-달렸-富士川町 = ', length('Cô-Chạy-Xuống-달렸-富士川町');
