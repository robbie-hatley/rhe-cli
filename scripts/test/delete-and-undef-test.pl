#!/usr/bin/perl

use v5.32;
use strict;
use warnings;

@::argle = (8,1,7,5,6,3,2,4);

print("Contents of array after assignment: @::argle.\n");

delete $::argle[6];

printf
(
   "After deleting element at index 6, exists returns %d, defined returns %d, and array length is %d.\n",
   exists($::argle[6]),
   defined($::argle[6]),
   scalar(@::argle),
);

undef $::argle[1];

printf
(
   "After undef-ing element at index 1, exists returns %d, defined returns %d, and array length is %d.\n",
   exists($::argle[1]),
   defined($::argle[1]),
   scalar(@::argle),
);
