#!/usr/bin/perl
use v5.32;
use strict;
use warnings;

open(GRADES, '<', 'grades') or die "Can't open grades: $!\n";

binmode(GRADES, ':encoding(utf8)');
binmode(STDOUT, ':encoding(utf8)');

my %grades;
while (my $line = <GRADES>) {
   my ($student, $grade) = split(" ", $line);
   if ($student)
   {
      $grades{$student} .= $grade . " ";
   }
}

for my $student (sort keys %grades) {
   my $scores = 0;
   my $total = 0;
   my @grades = split(" ", $grades{$student});
   for my $grade (@grades) {
      $total += $grade;
      $scores++;
   }
   my $average = $total / $scores;
   printf ("%-10s%-10s%-9s%6.1f\n", "$student:", $grades{$student}, "Average:", $average);
}


