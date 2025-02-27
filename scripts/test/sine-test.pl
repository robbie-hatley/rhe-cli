#!/usr/bin/perl
my $AngleDeg = $ARGV[0]; # degrees
my $Angle = ($AngleDeg/360)*2*3.14159; # radians
my $Sine = sin $Angle;
print "the sine of ", $ARGV[0], " degrees is ", $Sine;
