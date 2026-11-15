#!/usr/bin/env perl
# rhe-cli/scripts/perl-internals/error-messages.pl
use v5.40;
use Errno;
my %by_number;
for my $name (@Errno::EXPORT_OK) {
   if ( $name !~ /^E[A-Z0-9_]+$/ ) {
      warn "Name $name does not start with E.\n";
      next;
   }
   my $sub = Errno->can($name);
   if ( ! defined $sub ) {
      warn "\$sub is not defined.\n";
      next;
   }
   if ( 'CODE' ne reftype $sub ) {
      warn "$sub is not a code ref.\n";
      next;
   }
   my $number = $sub->();
   local $! = $number;
   $by_number{$number} = [$name, $number, $!]
}
for my $number (sort {$a<=>$b} keys %by_number) {
   printf "%-18s %3d  %s\n",
      $by_number{$number}->[0],
      $by_number{$number}->[1],
      $by_number{$number}->[2];
}
