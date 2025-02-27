#!/usr/bin/env -S perl -CSDA

# This is an 120-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# /rhe/scripts/test/name-dir-test.pl
# Tests subs "get_name_from_path" and "get_dir_from_path" in module
# "RH::Dir".
# Written by Robbie Hatley, 2020-03-22.
########################################################################################################################

use v5.32;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;

use RH::Util;
use RH::Dir;

my $test_path_1 = '/////';
say "Test Path 1 = $test_path_1";
say "Test Dir  1 = ", get_dir_from_path($test_path_1);
say "Test Name 1 = ", get_name_from_path($test_path_1);
say '';

my $test_path_2 = '/absdir';
say "Test Path 2 = $test_path_2";
say "Test Dir  2 = ", get_dir_from_path($test_path_2);
say "Test Name 2 = ", get_name_from_path($test_path_2);
say '';

my $test_path_3 = '/absdir/';
say "Test Path 3 = $test_path_3";
say "Test Dir  3 = ", get_dir_from_path($test_path_3);
say "Test Name 3 = ", get_name_from_path($test_path_3);
say '';

my $test_path_4 = '/absdir/filename';
say "Test Path 4 = $test_path_4";
say "Test Dir  4 = ", get_dir_from_path($test_path_4);
say "Test Name 4 = ", get_name_from_path($test_path_4);
say '';

my $test_path_5 = '/absdir/absdir2/';
say "Test Path 5 = $test_path_5";
say "Test Dir  5 = ", get_dir_from_path($test_path_5);
say "Test Name 5 = ", get_name_from_path($test_path_5);
say '';

my $test_path_6 = 'filename';
say "Test Path 6 = $test_path_6";
say "Test Dir  6 = ", get_dir_from_path($test_path_6);
say "Test Name 6 = ", get_name_from_path($test_path_6);
say '';

my $test_path_7 = 'reldir/';
say "Test Path 7 = $test_path_7";
say "Test Dir  7 = ", get_dir_from_path($test_path_7);
say "Test Name 7 = ", get_name_from_path($test_path_7);
say '';

my $test_path_8 = 'reldir/filename';
say "Test Path 8 = $test_path_8";
say "Test Dir  8 = ", get_dir_from_path($test_path_8);
say "Test Name 8 = ", get_name_from_path($test_path_8);
say '';

my $test_path_9 = 'reldir/reldir2/';
say "Test Path 9 = $test_path_9";
say "Test Dir  9 = ", get_dir_from_path($test_path_9);
say "Test Name 9 = ", get_name_from_path($test_path_9);
say '';
