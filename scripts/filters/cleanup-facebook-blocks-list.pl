#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# cleanup-facebook-blocks-list.pl
# Cleans up raw Facebook blocks-list files. (Launch floating Blocks List window, manually highlight,
# right-click-copy, then paste into a text file.)
#
# Written by Robbie Hatley on Monday April 14, 2015.
#
# Edit history:
# Mon Apr 14, 2015: Wrote it.
# Fri Jul 17, 2015: Upgraded for utf8.
# Thu Mar 10, 2016: Cleaned up a few things.
# Sat Apr 16, 2016: Now using -CSDA.
# Tue Nov 09, 2021: Refreshed shebang, colophon, and boilerplate.
# Wed Dec 08, 2021: Reformatted titlecard.
# Sat Sep 23, 2023: Upgraded Perl version from "v5.32" to "v5.36". Reduced width from 120 to 110. Got rid of
#                   CPAN module common::sense (antiquated). Got rid of RH::Winchomp (unnecessary).
# Wed Jul 31, 2024: Got rid of "use strict", "use warnings", and "use Sys::Binmode".
# Sat Aug 03, 2024: Ditched "Unicode::Collate" in favor of "sort", as I want weird codepoints obvious.
#                   Also got rid of uniq, because two people can have the same name.
# Sat Apr 12, 2025: Simplified.
##############################################################################################################

use v5.36;
use utf8::all;

my @unsorted;
my @sorted;

while (<>) {
   chomp;
   next if '' eq $_    ; # Skip this line if it's empty.
   next if m/^\s+$/    ; # Skip this line if it's whitespace-only.
   push @unsorted, $_  ; # Push line onto end of @unsorted.
}

# Sort and dedup names:
@sorted = sort {$a cmp $b} @unsorted;

# Print result:
say for @sorted;
