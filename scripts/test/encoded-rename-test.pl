#!/usr/bin/env -S perl -C63

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# encodeed-rename-test.pl
# Tries to rename a file using "rename" WITH encoding.
# Written by Robbie Hatley.
# Edit history:
# Mon May 12, 2025: Wrote it.
##############################################################################################################

use v5.36;
use Sys::Binmode;
use Encode qw( encode decode :fallbacks :fallback_all );
sub d ($x) {decode('UTF-8', $x, LEAVE_SRC|WARN_ON_ERR);}
sub e ($x) {encode('UTF-8', $x, LEAVE_SRC|WARN_ON_ERR);}
if ( 2 != scalar(@ARGV) ) {
   warn "Error: \"encoded-rename-test.pl\" needs exactly two arguments.\n"
       ."The first  argument must be a path to an existing file.\n"
       ."The second argument must be a valid path to rename the file to.\n"
       ."Aborting program execution.\n";
   exit 666;
}
my $f1 = $ARGV[0];
if ( ! -e e($f1) || ! -f e($f1) ) {
   warn "Error in \"encoded-rename-test\": File \"$f1\" does not exist.\n";
   exit 666;
}
my $f2 = $ARGV[1];
if ( -e e($f2) ) {
   warn "Error in \"encoded-rename-test\": A file named \"$f2\" already exists.\n";
   exit 666;
}
say "\"encoded-rename-test\" will attempt the following file rename with encoding:";
say "Original file path: $f1";
say "Proposed file path: $f2";
rename(e($f1),e($f2))
and say "Rename succeeded."
or  say "Rename failed.";
