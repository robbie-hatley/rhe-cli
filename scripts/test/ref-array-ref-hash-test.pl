#!/usr/bin/perl
# ref-array-ref-hash-test.pl
use v5.32;
my @MyArray;
push @MyArray, {'Name' => 'Bob',  'Age' => 37};
push @MyArray, {'Name' => 'Fred', 'Age' => 62};
my $MyRef = \@MyArray;
say 'size of array = ', scalar(@MyArray);
say "First  person's name is ", $MyRef->[0]->{'Name'};
say "First  person's age  is ", $MyRef->[0]->{'Age'};
say "Second person's name is ", $MyRef->[1]->{'Name'};
say "Second person's age  is ", $MyRef->[1]->{'Age'};
say "OR, bypassing the ref and using the array direct:";
say "First  person's name is ", $MyArray[0]->{'Name'};
say "First  person's age  is ", $MyArray[0]->{'Age'};
say "Second person's name is ", $MyArray[1]->{'Name'};
say "Second person's age  is ", $MyArray[1]->{'Age'};

