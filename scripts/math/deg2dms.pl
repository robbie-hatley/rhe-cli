#!/usr/bin/env -S perl -C63

# deg2dms.pl

use v5.16;
use utf8;
use Scalar::Util  qw( looks_like_number );
use Math::Trig    qw(        pi         );

for ( @ARGV ) {
   if ( !looks_like_number($_) ) {
      die "Error: Arguments must be numbers.\n";
   }
}

if ( scalar(@ARGV) > 1 ) {
   warn "Warning: Arguments after 1st will be ignored.\n";
}

# We can divide a degree into sixtieths as many times as we want:
# 1 minute  = 1/60 degree
# 1 second  = 1/60 minute
# 1 argblu  = 1/60 second
# 1 senska  = 1/60 argblu
# Etc, etc, etc. Sexagesimal is fun! :-)

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

say(qq($deg_int° $min_int′ $sec_int″ $arg_int‴ $sen_int⁗));
