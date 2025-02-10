#!/usr/bin/env perl
# "cylinder-volume.pl"
# Written by Robbie Hatley on-or-before 2024-08-14.
# Dramatically-simplified on 2025-02-10.
use Math::Trig 'pi';
print "Height? ";
my $Height = readline;
print "Radius? ";
my $Radius = readline;
print "Volume = ", (pi * $Radius * $Radius * $Height), "\n";
