#!/usr/bin/perl
use v5.32;
use strict;
use warnings;

our $Help    = 0;
our $prefix  = '(empty)';
our $dir1    = '(empty)';
our $dir2    = '(empty)';
our @Options;
our @Arguments;

sub get_options_and_arguments
{
   push /^-/ ? \@Options : \@Arguments , $_ for @ARGV ;
}

sub process_options_and_arguments
{
   foreach (@Options)
   {
      if ('-h' eq $_ || '--help' eq $_) {$Help = 1}
   }
   if (3 == @Arguments)
   {
      ($prefix, $dir1, $dir2) = @Arguments[0, 1, 2];
   }
}

get_options_and_arguments();
process_options_and_arguments();

$, = ' ';
say @Options;
say @Arguments;
say "Help    = $Help";
say "Prefix  = $prefix";
say "Dir 1   = $dir1";
say "Dir 2   = $dir2";
our $numargs = scalar @Arguments;
say "Error: need 3 args, you gave $numargs." if 3 != $numargs;
