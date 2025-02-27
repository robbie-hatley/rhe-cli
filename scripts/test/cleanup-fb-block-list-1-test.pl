#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
use open qw( :encoding(utf8) :std );
use Unicode::Collate;
use charnames ":short";

# Clean-up one line of text:
sub process_line (_) {
   s/[\x0a\x0d]+$//;         # Get rid of newline (Windows OR Unix).
   s/^\N{BOM}//;             # Get rid of BOM at start of line (if any).
   s/\s*(.+)\s+Unblock$/$1/; # Get rid of leading/trailing space & junk.
   $_ .= "\x0a";             # Add Unix-style newline.
}

# Process all lines and print the collated result:
print Unicode::Collate->new->sort( map {process_line} <> );
