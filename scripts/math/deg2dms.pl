#!/usr/bin/env -S perl -C63

# deg2dms.pl

use v5.16;
use utf8;
use Scalar::Util  qw( looks_like_number );
use Math::Trig    qw(        pi         );

sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);
   This program takes one argument, which must be a real numbers in
   the the -180 to +180 range. This input will be construed as a
   geographic longitude or latitude angle in degrees.
   Use positive angle for north latitude or east longitude.
   Use negative angle for south latitude ow west longitude.

   The output will be the corresponding angle in degrees, minutes, seconds,
   argblus, senskas, tenfors, and quelmos.
   1 minute = 1/60 degree
   1 second = 1/60 minute
   1 argblu = 1/60 second
   1 senska = 1/60 argblu
   1 tenfor = 1/60 senska
   1 quelmo = 1/60 tenfor
   Sexagesimal is fun! :-)

   For example:
   deg2dms.pl -118.254711506277
   -118 -15 -16 -57 -41 -7 -16 -51 -35
   which is the latitude of downtown Los Angeles, California.
   END_OF_HELP
   return 1;
}

for ( @ARGV ) {
   if ( !looks_like_number($_) ) {
      die "Error: Arguments must be numbers.\n";
   }
}

if ( scalar(@ARGV) > 1 ) {
   warn "Warning: Arguments after 1st will be ignored.\n";
}

my $deg_dec = $ARGV[0] // 0;
my $deg_int = int $deg_dec;
my $deg_frc = $deg_dec - $deg_int;

my $min_dec = 60 * $deg_frc;
my $min_int = int $min_dec;
my $min_frc = $min_dec - $min_int;

my $sec_dec = 60 * $min_frc;
my $sec_int = int $sec_dec;
my $sec_frc = $sec_dec - $sec_int;

my $arg_dec = 60 * $sec_frc;
my $arg_int = int $arg_dec;
my $arg_frc = $arg_dec - $arg_int;

my $sen_dec = 60 * $arg_frc;
my $sen_int = int $sen_dec;
my $sen_frc = $sen_dec - $sen_int;

my $ten_dec = 60 * $sen_frc;
my $ten_int = int $ten_dec;
my $ten_frc = $ten_dec - $ten_int;

my $que_dec = 60 * $ten_frc;
my $que_int = int $que_dec;
my $que_frc = $que_dec - $que_int;

say(qq($deg_int $min_int $sec_int $arg_int $sen_int $lem_int $bor_int $ten_int $que_int));
