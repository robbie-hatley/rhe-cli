#!/usr/bin/env perl

# This is a 110-character-wide ASCII Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# parallel-resistances.pl
# Calculates parallel resistances.
# Written by Robbie Hatley.
# Edit history:
# Mon Oct 21, 2024: Wrote it.
##############################################################################################################

use v5.36;

use List::Util 'sum0';

exit 0 if scalar(@ARGV) < 2;

say 1 / sum0 map {1/eval($_)} @ARGV;
