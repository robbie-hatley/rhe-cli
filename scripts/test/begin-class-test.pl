#!/usr/bin/perl
#  begin-class-test.pl
use v5.32;
use strict;
use warnings;

BEGIN: {
   # my damn class
   my $text    = '';
   my $regex   = '';
   my @matches = ();

   sub set_text
   {
      $text = shift;
   }

   sub set_regex
   {
      $regex = shift;
   }

   sub print_results
   {
      say '';
      say "\$text  = $text";
      say "\$regex = $regex";
      my @matches = $text =~ m/$regex/;
      say("\@matches = ", join(' ', @matches));
      say "\$` = $`";
      printf("Length of \$` = %d\n", length($`));
      say "\$& = $&";
      printf("Length of \$& = %d\n", length($&));
      say "\$' = $'";
      printf("Length of \$' = %d\n", length($'));
   }
}

set_text('Freddy');

set_regex(qr{(r)(e??)(d?)});
print_results;

set_regex(qr{(r)(e?)(d?)});
print_results;

