#!/usr/bin/perl
# sum-prod-mean-test.pl
use v5.32;
use List::Util 'sum', 'product';
exit if scalar(@ARGV)<1 || scalar(@ARGV)>100;
say "Number  of numbers: ", scalar  ( @ARGV );
say " Sum    of numbers: ", sum     ( @ARGV );
say "Product of numbers: ", product ( @ARGV );
say " Mean   of numbers: ", product(@ARGV)/sum(@ARGV);
