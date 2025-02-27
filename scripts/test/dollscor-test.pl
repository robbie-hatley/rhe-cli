#!/usr/bin/perl
#dollscor
#A test of the $_ ("dollar-underscore" or "dollscor") variable.
#This program does nothing other than print itself.
open my $F, $0 or die $!;
while (<$F>)
{
   print $_ ;  # Print a line of this program.
}
close $F;
