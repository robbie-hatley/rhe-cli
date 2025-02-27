#!/usr/bin/perl
#  /rhe/scripts/test/reference-return-test.pl
use v5.32;
use strict;
use warnings;
use open qw( :encoding(utf8) :std );

our @seri_num_refs;

sub serial_number_generator {
   state $number = 0;
   ++$number;
   my $lexial_copy = $number;
   return \$lexial_copy;
}

for (0..19) {
   my $seri_num_ref = serial_number_generator();
   push @seri_num_refs, $seri_num_ref;
}

for (0..19) {
   printf("${$seri_num_refs[$_]}\n");
}


