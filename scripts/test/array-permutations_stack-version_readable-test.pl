#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# array- permutations_stack-version_readable.pl
# This program places all of its non-option arguments in an array, then prints both the original array and
# all possible permutations thereof.
# Written by Robbie Hatley.
# Edit history:
# Sat Jun 05, 2021: Wrote it.
# Sat Sep 09, 2023: Brought formatting up to my current standards.
##############################################################################################################

use v5.36;
use strict;
use warnings;
use utf8;
use warnings FATAL => 'utf8';

use Sys::Binmode;
use Time::HiRes 'time';

sub permutations ( @array ) {
   my @permutations;             # Our output will go in here.
   my @stack = ([[@array],[]]);  # A 3D array!!! OMG, WTF???
   while ( @stack ) {
      my $old_pair = shift @stack;
      my $old_raw  = $old_pair->[0];
      my $old_ckd  = $old_pair->[1];
      my $raw_size = scalar(@{$old_raw});
      if ( 0 == $raw_size ) {
         push @permutations, $old_ckd;
      }
      else {
         for ( my $idx = 0 ; $idx < $raw_size ; ++$idx ) {
            my @new_raw = @$old_raw;
            my @new_ckd = @$old_ckd;
            my $cut = splice @new_raw, $idx, 1;
            push @new_ckd, $cut;
            my $new_pair = [\@new_raw, \@new_ckd];
            push @stack, $new_pair;
         }
      }
   }
   return @permutations;
}

{ # begin main
   my $t0 = time;
   my @array = (@ARGV);
   say "Array = " . "(" . join(', ', map {"\"$_\""} @array) . ")";
   my @permutations = permutations(@array);
   say "Number of permutations = ", scalar(@permutations);
   #say "Permutations:";
   #for my $aref ( @permutations ) {
   #   say "(", join(', ', map {"\"$_\""} @$aref), ")";
   #}
   my $t1 = time; my $te = $t1 - $t0;
   say "\nExecution time was $te seconds.";
   exit 0;
} # end main
__END__
