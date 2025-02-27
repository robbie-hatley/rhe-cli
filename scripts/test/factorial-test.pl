#!/usr/bin/perl
# factorial.pl
# Copyright Robbie Hatley, Monday April 16, 2018
use v5.32;
use Math::BigInt;
say("$_! = ${\Math::BigInt->bfac($_)}") for ($ARGV[0]..$ARGV[1]);
