#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
use open qw( :encoding(utf8) :std );
use Unicode::Collate;
use charnames ":short";

sub winchomp (_) {
   s/[\x0a\x0d]+$//;
}

sub remove_bom (_) {
   s/^\N{BOM}//;
}

sub add_unix_newline (_) {
   $_ .= "\x0a";
}

print Unicode::Collate->new->sort( map {  # Unicode alphabetical collate.
   winchomp;                              # Get rid of windows newline.
   remove_bom;                            # Get rid of BOM.
   s/\s*(.+)\s+Unblock$/$1/;              # Get rid of detritus.
   add_windows_newline;                   # Add windows newline.
} <> );                                   # Read from files or STDIN.
