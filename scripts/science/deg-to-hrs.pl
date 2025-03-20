#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# deg-to-hrs.pl
# Converts longitude difference (in degrees) to solar-time difference (in floating-point hours).
# Written by Robbie Hatley.
# Edit history:
# Thu Mar 20, 2025: Wrote it.
##############################################################################################################

my $Hrs = 12*$ARGV[0]/180;
print "$Hrs hours\n";
