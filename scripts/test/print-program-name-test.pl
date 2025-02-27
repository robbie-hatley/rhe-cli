#!/usr/bin/perl
# print-program-name-test.pl
use v5.36;
say$0=~s%^.*/%%r;
say$0=~/[^\/]+$/g;
$0=~/.*\//;say$';
$0=~/[^\/]+$/;say$&;
/[^\/]+$/,say$&for$0;
say [split m%/%,$0]->[-1];
say [split /\//,$0]->[-1];
say @{[split /\//,$0]}[-1];
say pop @{[split /\//,$0]};
say substr $0,1+rindex $0,'/';
say splice @{[split /\//,$0]}, -1;
say shift @{[reverse split /\//,$0]};
{use File::Basename; say basename($0);}
say shift @{[reverse @{[split /\//, $0]}]};
