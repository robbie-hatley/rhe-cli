#!/usr/bin/perl

use v5.32;
use strict;
use warnings;
use Statistics::Descriptive;

sub StatSub {
   my @list    = sort @_;
   my $count   = 0;
   my $sum     = 0;
   my $median  = 0;
   my $mean    = 0;
   my $std_dev = 0;

   foreach my $item (@list) {
      ++$count;
      $sum += $item;
   }
   $median = $list[int($count/2)];
   $mean   = $sum/$count;
   return ($count, $sum, $median, $mean, $std_dev);
}

our @list = (17.8,  37.6, 92.3, 24.9, 43.2, 84.7, 13.5, 33.4);
$" = ", ";

do {
   print "\nstats subroutine test:\n\n";
   print("List = @list\n");
   my ($count, $sum, $median, $mean, $std_dev) = StatSub(@list);
   say("Count = $count");
   say("Sum = $sum");
   say("Median = $median");
   say("Mean = $mean");
   say("Std Dev = $std_dev");
};

do {
   print "\nStatistics::Descriptive test:\n\n";
   my $stats = Statistics::Descriptive::Full->new();
   $stats->add_data(@list);
   my ($count, $sum, $median, $mean, $var, $std_dev) =
      ($stats->count(), $stats->sum(), $stats->median(), $stats->mean(),
       $stats->variance(), $stats->standard_deviation() );
   print("List = @list\n");
   say("Count = $count");
   say("Sum = $sum");
   say("Median = $median");
   say("Mean = $mean");
   say("Variance = $var");
   say("Std Dev = $std_dev");
};
