#!/usr/bin/perl
use v5.36;
my $auto_id = 0;
sub foo ($thing, $id = $auto_id++) {
   say "$thing has ID $id";
}
foo("bat");
foo("cat", 17);
foo("rat");
