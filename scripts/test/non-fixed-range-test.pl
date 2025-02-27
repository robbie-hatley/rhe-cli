#!/usr/bin/env perl
use v5.38;
sub complete_days (@times) {
   my $cds = 0;
   for    my $i (    0   .. $#times - 1 ) {
      for my $j ( $i + 1 .. $#times - 0 ) {
         0 == ($times[$i]+$times[$j])%24 and ++$cds;
      }
   }
   $cds;
}
my @arrays =
(
   # Example 1 input:
   [12, 12, 30, 24, 24],
   # Expected output: 2

   # Example 2 input:
   [72, 48, 24, 5],
   # Expected output: 3

   # Example 3 input:
   [12, 18, 24],
   # Expected output: 0
);
$"=', ';
for my $aref (@arrays) {
   say '';
   my @times = @$aref;
   say "Times = (@times)";
   my $cds = complete_days(@times);
   say "Complete days = $cds";
}
