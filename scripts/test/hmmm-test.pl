#!/usr/bin/perl
*{*::Y = do $0} = \ 1;
print STDOUT *{ $::Y }, "\n";
