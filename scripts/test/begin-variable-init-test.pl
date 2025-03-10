#!/usr/bin/perl
# begin-variable-init-test.pl
use strict;
use warnings;
our $x = 5;
my  $y = 6;

BEGIN {print "In BEGIN block. \$x = $x and \$y = $y\n"}

print "In main body of script. \$x = $x and \$y = $y\n";
$x = 7;
$y = 8;
exit;

END {print "In END block. \$x = $x and \$y = $y\n"}

=pod
Result: Shows that while the "our|my $varname" part of "our|my" statements is executed before BEGIN{},
the " = value;" part is deferred until after any BEGIN{} blocks a run.
=cut
