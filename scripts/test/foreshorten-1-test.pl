#!/usr/bin/perl
#  ~/scripts/test/foreshorten.pl
our @array;
for ( my $i = 1 ; $i <= 100 ; ++$i ) {push(@array,$i);}
$#array = 49;
# After that last line, @array is now a 50-element array containing
# the integers 1 through 50. An attempt to access $array[73] will not
# be considered an error, but will yield the "undefined" value.
print("$array[24]\n"); # prints 25
print("$array[73]\n"); # prints blank line (because $array[73] is undefined)
$#array = -1; # erase the whole damn array
print("$array[ 0]\n"); # prints blank line (because $array[ 0] is undefined)
print("$array[13]\n"); # prints blank line (because $array[13] is undefined)
print("$array[62]\n"); # prints blank line (because $array[62] is undefined)
