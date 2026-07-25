#!/usr/bin/env perl

##############################################################################################################
# double-case.pl
# Foldcases, sorts, and dedups the lines of a file, then replaces each unique line with the lower-cased
# version followed by the first-cased version. This program is very useful for processing Firefox's
# dictionaries, which need both the lower-cased and the first-cased version of each word.
# Written by Robbie Hatley.
# Edit history:
#    Tue Sat Jun 27, 2026:
#       Wrote it.
##############################################################################################################

use utf8::all;
use Cwd::utf8;
use List::Util qw( uniq );

# FIrst-case a string:
sub fi {
   my $string = lc shift;
   substr($string, 0, 1, uc substr($string, 0, 1));
   $string;
}

# Fold-case <>, sort it, dedup it:
my @unique = uniq sort {$a cmp $b} map {fc $_} <>;

# For each unique fold-cased string in lexical order,
# first print the lower-cased verion,
# then  print the first-cased version:
for my $line (@unique) {
   print lc $line;
   print fi $line;
}
