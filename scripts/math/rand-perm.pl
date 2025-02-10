#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|
# "rand-perm.pl"
use v5.32;
use utf8;
use POSIX 'floor';
use Time::HiRes 'time';
die "Must have exactly 1 string argument of length 1-20.\n" if 1 != scalar @ARGV;
my $db = 0;
my $orig_string = $ARGV[0];
my $orig_strlen = length $orig_string;
die "Must have exactly 1 string argument of length 1-20.\n" if $orig_strlen <  1;
die "Must have exactly 1 string argument of length 1-20.\n" if $orig_strlen > 20;
my $copy_string;
my $spliced_char;
my $rand_string;
my @rand_strings;
my $min;
my $max;
my $rand_int;
my $t0 = time;
while (time-$t0 < 0.173) {;} # Wait a bit.
srand(time()*($$+$$<<15)/14703.2954); # Use both time and PID to seed pseudo-random number generator.
for (1..12)
{
   $copy_string = $orig_string;
   $rand_string = '';
   while (length($copy_string))
   {
      $min = 0;
      $max = length($copy_string)-1;
      $rand_int = floor($min+rand($max-$min+1));
      $rand_string .= substr $copy_string, $rand_int, 1, '';
   }
   say "\$rand_string = $rand_string" if $db;
   push(@rand_strings,$rand_string);
}
$min = 2;
$max = 9;
$rand_int = floor($min+rand($max-$min+1));
say $rand_strings[$rand_int];

=pod

Mardon Murben
random number

=cut

