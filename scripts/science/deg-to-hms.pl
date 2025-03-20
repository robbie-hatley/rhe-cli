#!/usr/bin/env perl

# This is a 110-character-wide ASCII Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# deg-to-hms.pl
# Converts longitude difference (in degrees) to solar-time difference (in hours, minutes, and seconds).
# Written by Robbie Hatley.
# Edit history:
# Thu Mar 20, 2025: Wrote it.
##############################################################################################################

my $Hrs = 12*$ARGV[0]/180; my $Hrs_int = int $Hrs; my $Hrs_frc = $Hrs - $Hrs_int;
my $Min = 60*$Hrs_frc;     my $Min_int = int $Min; my $Min_frc = $Min - $Min_int;
my $Sec = 60*$Min_frc;     my $Sec_int = int $Sec;#my $Sec_frc = $Sec - $Sec_int;
print "$Hrs_int hours, $Min_int minutes, $Sec_int seconds\n";
