#!/usr/bin/perl

use v5.32;
use strict;
use warnings;

my $argle = 'ARGLE!!!';

system("echo '\"Surprise!\"'");

eval('slfheydt');
if($@){print('$@ #1 = ', "$@");}

eval('print("Abra kadabra!\n");');
if($@){print('$@ #2 = ', "$@");}

exec( {'echo'} 'echo', 'surprise')
|| die "exec: $!";

print('THIS WILL NEVER BE PRINTED.');
