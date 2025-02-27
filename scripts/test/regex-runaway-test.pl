#!/usr/bin/perl

# This is a 120-character-wide ASCII Perl source-code text file.
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# /rhe/scripts/test/regex-runaway.pl
# Tests a run-away condition with regular expressions.
# Edit history:
#    ??? ??? ??, 20?? - Wrote it.
#    Thu Jul 16, 2015 - Minor corrections.
########################################################################################################################

use v5.32;
use strict;
use warnings;

my $A = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
print "Matched.\n" if $A =~ m/a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*[b]/;
