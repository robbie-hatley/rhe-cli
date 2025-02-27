#!/usr/bin/perl

########################################################################################################################
# /rhe/scripts/test/multi-line-test.pl
# Tests syntax of multi-line-print command.
#
# Edit history:
#    Tue Oct 16, 2019: Wrote it.
########################################################################################################################

use v5.32;
use strict;
use warnings;

sub mlprint ();

# main()
{
   mlprint();
   exit 0;
}

sub mlprint ()
{
print <<'END_OF_TEST';
Tortor pretium viverra suspendisse potenti nullam ac
Non blandit massa enim nec dui nunc mattis enim
Quam lacus suspendisse faucibus interdum posuere
Consectetur adipiscing elit ut aliquam purus sit
Amet luctus venenatis aenean euismod elementum nisi
Quis eleifend tellus in metus vulputate eu scelerisque
Felis imperdiet justo laoreet sit amet cursus id nibh
END_OF_TEST
return 1;
}
