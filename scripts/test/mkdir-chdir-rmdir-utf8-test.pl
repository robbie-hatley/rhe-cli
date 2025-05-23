#!/usr/bin/env -S perl -CSDA
# mkdir-chdir-rmdir-utf8-test.pl
use v5.32;
use strict;
use warnings;
use utf8;
use warnings FATAL => "utf8";

use Encode;

use RH::Dir;

chdir(e('/D/test-range/unicode-test'))     or die "Couldn't cd to test range.             \n$!\n";
mkdir(e('蜰粨мéЦPJÊ'))                       or die "Couldn't  make test directory.         \n$!\n";
chdir(e('蜰粨мéЦPJÊ'))                       or die "Couldn't cd to test directory.         \n$!\n";
say 'New current directory is ', d(getcwd) or die "Couldn't determine new cwd.            \n$!\n";
say 'Returning to unicode-test...';
chdir(e('..'))                             or die "Couldn't return to previous directory. \n$!\n";
say 'Erasing 蜰粨мéЦPJÊ...';
rmdir(e('蜰粨мéЦPJÊ'))                       or die "Couldn't remove test directory.        \n$!\n";
say 'Test successful.';
