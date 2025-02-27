#!/usr/bin/perl
# add-file-numbers-test.pl
use v5.32;

my @numbers  = ();
my $total    = 0;
my $fh       = undef;

open($fh, '<', '/cygdrive/d/test-range/misc/myfile.txt')
or die "Couldn't open file.\n$!\n";
while (<$fh>)
{
   s/\s+$//;                  # chop-off trailing whitespace
   push @numbers, split / /;  # split line into numbers
}
close $fh;
$total += $_ for (@numbers);
say $total;
