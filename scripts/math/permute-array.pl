#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

# "permute-4.pl"
# Given a string of 2-20 characters, Permute4.pl calculates and prints
# all possible permutations of the characters of the string.
# (Array-based version. This seems to be much slower than the string version.)

use v5.32;
use utf8;

sub Permute {
   my $left  = shift;
   my $right = shift;
   my $length_left  = scalar(@{$left});
   my $length_right = scalar(@{$right});

   if (2 == $length_right) {
      say(@{$left},@{$right});
      say(@{$left},reverse @{$right});
   }
   else {
      foreach (0..$length_right-1) {
         my @temp_left  = @{$left};
         my @temp_right = @{$right};
         $temp_left[$length_left] = splice(@temp_right, $_, 1);
         Permute(\@temp_left, \@temp_right);
      }
   }
   return 1;
}

warn("Entry time: ", time, "\n");

# die if not exactly 1 arg:
if (1 != scalar(@ARGV)) {
   die "Error: Permute takes exactly 1 argument, which must be\n".
         "a string with at least 2 characters and at most 20 characters.\n";
}

# die if arg is too short or too long:
if (length($ARGV[0]) < 2 || length($ARGV[0]) > 20) {
   die "Error: Permute takes exactly 1 argument, which must be\n".
         "a string with at least 2 characters and at most 20 characters.\n";
}

my @LeftArray  = ();
my @RightArray = split(//,$ARGV[0],20);

Permute(\@LeftArray, \@RightArray);

warn("Exit  time: ", time, "\n");
