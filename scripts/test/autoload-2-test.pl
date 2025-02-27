#!/usr/bin/env -S perl -CSDA
#  autoload-test-2.pl
use v5.32;
use utf8;
no strict;
no warnings;

sub AUTOLOAD
{
   my $program = our $AUTOLOAD;
   $program =~ s/.*:://; # trim package name
   system($program, @_);
}

system('td');

