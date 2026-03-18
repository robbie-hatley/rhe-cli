#!/usr/bin/env perl
# plasmarc-refresh.pl
use v5.42;
use utf8::all;
sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);
   Welcome to "plasmarc-refresh.pl". This program, once customized for your
   system, will write all of the paths of your desktop background pictures
   to your Plasma resources file, to greatly ease choosing them from the picker
   without having to manually add each one individually.

   Tip: This program will only work for you if you are using Gnu-Linux with
   KDE Plasma desktop; otherwise, it will be useless for you.

   Tip: This program will only work for you if you first edit it to change
   '/d/OS-Resources/Background-Pictures' to the actual location of your
   desktop background pictures.

   Tip: This program will only work for you if you also have my scripts
   'list-paths.pl' and 'plasmarc-join.pl' installed on your system.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help

for (@ARGV) {/--help/ || /-h/ and help and exit}

chdir '/c/OS-Resources/Background-Pictures';
system 'list-paths.pl -fqr | extract-image-paths.pl | plasmarc-join.pl';
