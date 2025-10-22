#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# wcount.pl
# Prints count of words within paragraphs of 50+ characters in a file.
#
# Edit history:
# Tue Oct 21, 2025: Wrote it.
##############################################################################################################

use v5.36;
use utf8::all;
my $wcount = 0;
while (<>) {chomp;next if 50 > length $_;$wcount += scalar split /\s+/, $_;}
say $wcount;
