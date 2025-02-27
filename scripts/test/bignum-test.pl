#!/usr/bin/perl
# bignum-test.pl
use v5.32;
use warnings;

use Math::BigFloat;
use Math::BigInt upgrade => 'Math::BigFloat';

say(Math::BigInt->bpi(3)   );     # 3.14
say(Math::BigInt->bpi(100) );   # 3.1415....
