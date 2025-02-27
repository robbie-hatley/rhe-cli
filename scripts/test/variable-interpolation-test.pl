#!/usr/bin/perl
my $Inner =  q{All along the watchtower, princes kept their view.};
my $Middl =  q{I said, "$Inner"!};
my $Outer = qq{Don't do that!  $Middl};
print $Outer;

