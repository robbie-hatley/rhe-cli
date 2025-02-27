#!/usr/bin/env -S perl -CSDA
use v5.32;
use strict;
use warnings;
use utf8;

say "What's your name?";
chomp(my $私 = <STDIN>);
say "what's the breed of your dog?";
chomp(my $犬 = <STDIN>);

printf(STDOUT "\nYour name is %s.\nThe breed of your dog is %s.\n", $私, $犬);
