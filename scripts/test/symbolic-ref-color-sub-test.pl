#!/usr/bin/perl
use v5.32;
use strict;
use warnings;

BEGIN
{
   our @colors = qw(red blue green yellow orange purple violet);
   for my $name (@colors)
   {
      no strict "refs"; # Allow symbolic references
      *name = *{uc $name} = sub { "<FONT COLOR='$name'>$_[0]</FONT>" };
   }
}

say "Eventually, we ", BLUE("want"), " to have ",
   GREEN("control"), " over color.";
