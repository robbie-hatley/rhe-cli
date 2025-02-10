#!/usr/bin/env perl
sub c {
   my $x = shift;
   0 == $x%2
   ? return $x/2
   : return 3*$x+1;
}
my $x=$ARGV[0];
my $n = 0;
while (1) {
	print("$x\n");
	last if 1 == $x;
	$x = c($x);
	++$n;
}
print "Total Stopping Time = $n\n";
