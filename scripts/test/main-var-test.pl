#!/usr/bin/perl
# main-var-test.pl
use v5.32;
use strict;
use warnings;

$main::var = 0x65;
printf("\$::var : %d\n", $main::var);
printf("oct(\$::var) : %d\n", oct($main::var));
exit 0;
