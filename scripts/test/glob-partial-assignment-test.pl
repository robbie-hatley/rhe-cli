#!/usr/bin/env perl
$bar = 1;
*foo = \$bar;
{
   local $bar = 2;
   print $foo;
}
