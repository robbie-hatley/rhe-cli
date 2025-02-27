#!/usr/bin/perl

# Character Input Test

use v5.32;
use strict;
use warnings;
use Term::Readkey;
sub GetCharacter;

while(1)
{
   print("Type a key: ");
   my $c = GetCharacter;
   print("   You typed ", $c, " \n");
   last if "q" eq $c;
}

sub GetCharacter {
   system "stty cbreak </dev/tty >/dev/tty 2>&1";
   my $char = getc;
   system "stty icanon </dev/tty >/dev/tty 2>&1";
   return $char;
}
