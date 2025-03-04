#!/usr/bin/env perl

# "robbie-hatley-explained.pl"

# Start with a string (a hex number in this case):
my $string = "526f62626965204861746c6579E";

# Declare an array to hold the desired 2-char snippets:
my @array;

# Snip snippets from string and put in array:
while ($string) {push @array, substr($string,0,2,"");}

# How big is array?
print("Array has ", scalar(@array), " elements.\n");

# What's in element 13?
print("Element 13 = ", $array[13], "\n");

# Say, those look like ASCII codes, don't they?
for (@array) {print chr(hex($_));}
print "\n";
