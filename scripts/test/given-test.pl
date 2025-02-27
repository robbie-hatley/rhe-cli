#!/usr/bin/perl

use v5.32;
use strict;
use warnings;

$::i = 0;

given (<STDIN>)
{
   default {++$::i; say $::i;}
}
