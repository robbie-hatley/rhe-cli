#!/usr/bin/perl
use v5.32;
use strict;
use warnings;

%::fav_foods = (
   "dog"       => "bone",
   "cat"       => "chicken",
   "rat"       => "meatloaf",
   "bat"       => "cricket"
);

@::fav_foods = sort @::fav_foods{keys %::fav_foods};
say join " ", @::fav_foods;

my %Longday;
my @Longday;

%Longday = (
   "Sun" => "Sunday",
   "Mon" => "Monday",
   "Tue" => "Tuesday",
   "Wed" => "Wednesday",
   "Thu" => "Thursday",
   "Fri" => "Friday",
   "Sat" => "Saturday",
);

@Longday = %Longday;

print join " ", @Longday;
