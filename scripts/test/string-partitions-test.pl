#!/usr/bin/perl
# string-partitions-test.pl

use v5.36;

sub string_partitions_recurser ($string, $current_partition, $partitions) {
   my $l = length $string;
   if ( 0 == $l ) {
      push @$partitions, [@$current_partition];
      return;
   }
   for ( my $i = 1 ; $i <= $l ; $i++ ) {
      my $left  = substr($string,  0, $i -  0);
      my $right = substr($string, $i, $l - $i);
      push @$current_partition, $left;
      string_partitions_recurser($right, $current_partition, $partitions);
      pop @$current_partition;
   }
}

sub string_partitions ($string) {
   my @partitions;
   string_partitions_recurser($string, [], \@partitions);
   return @partitions;
}

die if 1 != scalar(@ARGV);
my $string = $ARGV[0];
my @partitions = string_partitions($string);
foreach my $partition (@partitions) {
   my $part_string = join ", ", @$partition;
   say "($part_string)";
}
