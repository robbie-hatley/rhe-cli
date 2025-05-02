#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# array-permutations.pl
# This program places all of its non-option arguments in an array, then prints both the original array and
# all possible permutations thereof.
# Written by Robbie Hatley.
# Edit history:
# Sat Jun 05, 2021: Wrote it.
# Sat Sep 09, 2023: Brought formatting up to my current standards.
# Wed Aug 14, 2024: Removed unnecessary "use" statements.
# Wed Feb 26, 2025: Uncommented printing of permutations.
# Tue Mar 04, 2025: Simplified main body. Got rid of parents, quotes, and commas in output for now.
# Thu May 01, 2025: Now using "utf8::all". Simplified shebang to "#!/usr/bin/env perl".
##############################################################################################################

use v5.36;
use utf8::all;
use Time::HiRes 'time';

sub permutations ( @array ) {
   my @permutations;
   my $size = scalar(@array);
   if ( 0 == $size ) {
      @permutations = ([]);
   }
   else {
      for ( my $idx = 0 ; $idx <= $#array ; ++$idx ) {
         my @temp = @array;
         my $removed = splice @temp, $idx, 1;
         my @partials = permutations(@temp);
         unshift @$_, $removed for @partials;
         push @permutations, @partials;
      }
   }
   return @permutations;
}

$" = ' ';
my $t0 = time;
say "Array = @ARGV";
my @permutations = permutations(@ARGV);
my $n = scalar(@permutations);
say "Number of permutations = $n";
say "Permutations:";
for my $aref ( @permutations ) {
   say "@$aref";
}
my $t1 = time;
my $te = $t1 - $t0;
say "\nExecution time was $te seconds.";
