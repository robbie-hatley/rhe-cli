#!/usr/bin/env -S perl -CSDA
#  autoload-test.pl
use v5.32;
use warnings;
use utf8;

sub AUTOLOAD
{
   our $AUTOLOAD;
   warn "Attempt to call $AUTOLOAD failed.\n";
}

blarg(10); # our $AUTOLOAD will be set to main::blarg

print "Still alive!\n";
