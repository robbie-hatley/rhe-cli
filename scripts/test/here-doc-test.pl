#!/usr/bin/env -S perl -CSDA

########################################################################################################################
# /rhe/scripts/test/here-doc-test.pl
########################################################################################################################

use v5.32;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;
no warnings 'experimental::smartmatch';
use RH::Util;
use RH::Dir;

sub help_msg;

help_msg;
exit 0;

sub help_msg
{
print <<'END_OF_HELP';
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Mauris cursus mattis
molestie a iaculis at erat pellentesque adipiscing. Sapien et ligula
ullamcorper malesuada proin libero. Proin fermentum leo vel orci porta
non pulvinar neque. Lacus vestibulum sed arcu non odio euismod lacinia.
Et leo duis ut diam quam.
END_OF_HELP
return 1;
} # end sub help_msg
