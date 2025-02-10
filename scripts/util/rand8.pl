#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# rand8.pl
# "rand8" prints strings of 8 random lower-case English letters. By default it prints 10 strings, but if 1-or-more
# arguments are given, and if the first argument has a positive-integer numeric value in the [1,1000] range,
# "rand8" will print that number of strings.
#
# Edit History:
# Wed Oct 28, 2020: Wrote it.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and "Sys::Binmode".
# Mon Aug 14, 2023: Upgraded from "v5.32" to "v5.38". Got ride of "common::sense".
########################################################################################################################

use v5.32;
use strict;
use warnings;

use RH::Util;

my $num = 10;
$num = $ARGV[0] if scalar(@ARGV) > 0
                && $ARGV[0] =~ m/^\d+$/
                && $ARGV[0] >=    1
                && $ARGV[0] <= 1000;
for (my $i = 0; $i < $num; ++$i)
{
   say(eight_rand_lc_letters());
}
