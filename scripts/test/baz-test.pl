#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
no  warnings qw( experimental numeric );

my $x = ''; $x = shift if @ARGV;
given ($x)
{
   when([qw(foo bar)] && /baz/)
   {
      say "YES";
   }
   default
   {
      say "NO";
   }
}

=pod

I think what's going on here is something like this:

when([qw(foo bar)] && /baz/)
=>
(
   Numeric($x)
   ~~
   (
      Numeric([qw(foo bar)]))
      &&
      Numeric($x =~ m/baz/))
   )
)

But the boolean value of an array ref is always 1,
so this is actually:

when([qw(foo bar)] && /baz/)
=>
(
   (BooleanScalar($x) ~~ 1)
   &&
   (NumericScalar($x) ~~ NumericScalar($x =~ m/baz/))
)



and the NumericScalar value of an non-empty string is always 0.

So for all non-numeric, non-empty, non-"baz" arguments,
the program always prints "YES".




=cut

