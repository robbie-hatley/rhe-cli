#!/usr/bin/env perl
if (1 != scalar @ARGV) {
   die "Error: Must have exactly 1 argument,\n"
     . "which must be an integer 0-1473.\n";
}
my $n=$ARGV[0];
if ($n !~ m/^0$|^[1-9]\d*$/) {
   die "Error: Argument must be an integer 0-1473.\n";}
if ($n > 1473) {
   die "Error: Argument must be an integer 0-1473.\n";
}
print((((1+sqrt(5))/2)**($n+1)-((1-sqrt(5))/2)**($n+1))/sqrt(5));
