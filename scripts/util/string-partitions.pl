#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# string-partitions.pl
# This program places all of its non-option arguments in an array, then prints both the original array and
# all possible permutations thereof.
# Written at an unknown time (2005-2024) by Robbie Hatley.
# Edit history:
# ??? ??? ??, 20??: Wrote it.
# Wed Aug 14, 2024: Brought formatting up to my current standards.
# Wed Feb 26, 2025: Added colophon and title block and changed shebang to "#!/usr/bin/env -S perl -C63".
##############################################################################################################

use v5.36;
use utf8;
$, = ' ';

sub string_partitions ($string) {
   my @partitions;
   my $size = length($string);
   if ( 0 == $size )
   {
      @partitions = ([]);
   }
   else
   {
      my ($first, $second);
      for ( my $part = 1 ; $part <= $size ; ++$part )
      {
         $first  = substr($string, 0,     $part        );
         $second = substr($string, $part, $size - $part);
         my @partials = string_partitions($second);
         for (@partials) {unshift @$_, $first;}
         push @partitions, @partials;
      }

   }
   return @partitions;
}

for (@ARGV)
{
   say '';
   say "All possible partitions of \"$_\":";
   for (string_partitions($_)) {
      say @$_;
   }
}
