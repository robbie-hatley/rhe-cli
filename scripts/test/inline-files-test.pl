#!/usr/bin/perl
# data-test.pl
use v5.32;
use Inline::Files;

if (@ARGV > 0 && ($ARGV[0] eq '-e' || $ARGV[0] eq '--error')) {print <ERROR>;}
if (@ARGV > 0 && ($ARGV[0] eq '-h' || $ARGV[0] eq '--help' )) {print <HELP>;}
if (@ARGV > 0 && ($ARGV[0] eq '-d' || $ARGV[0] eq '--data' )) {print <DATA>;}

__ERROR__
Error! Error! Data does not compute!
Your "facts" are uncoordinated!

__HELP__
Seven time she screamed in rage;
seven times she smote her foe.
Finally, after her seventh blow,
her foe fell lifeless.

__DATA__
If this had been a real program,
there would be some actual data here;
but it isn't, so there isn't.

