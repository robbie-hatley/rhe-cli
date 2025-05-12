#!/usr/bin/env -S perl -C63

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# encodeless-rename-test.pl
# Tries to rename a file using "rename" without encoding.
# Written by Robbie Hatley.
# Edit history:
# Mon May 12, 2025: Wrote it.
##############################################################################################################

use v5.36;
use Sys::Binmode; # Include this to enforce need for encoding anything sent to sys-call wrappers (eg, rename).
use Encode qw( encode decode :fallbacks :fallback_all );
sub d ($x) {decode('UTF-8', $x, LEAVE_SRC|WARN_ON_ERR);}
sub e ($x) {encode('UTF-8', $x, LEAVE_SRC|WARN_ON_ERR);}
if ( 2 != scalar(@ARGV) ) {
   warn "Error: \"encodeless-rename-test.pl\" needs exactly two arguments.\n"
       ."The first  argument must be a path to an existing file.\n"
       ."The second argument must be a valid path to rename the file to.\n"
       ."Aborting program execution.\n";
   exit 666;
}
my $f1 = $ARGV[0];
if ( ! -e e($f1) || ! -f e($f1) ) {
   warn "Error in \"encodeless-rename-test.pl\": File \"$f1\" does not exist.\n";
   exit 666;
}
my $f2 = $ARGV[1];
if ( -e e($f2) ) {
   warn "Error in \"encodeless-rename-test.pl\": A file named \"$f2\" already exists.\n";
   exit 666;
}
say "\"encodeless-rename-test.pl\" will attempt the following file rename without encoding:";
say "Original file path: $f1";
say "Proposed file path: $f2";
rename($f1,$f2)
and say "Rename succeeded."
or  say "Rename failed.";

=pod

WITHOUT "use Sys::Binmode;", this program sometimes suceeds and sometimes fails, unpredictably.

WITH "use Sys::Binmode;", this program ALWAYS fails with "Wide character in rename" error, if either name
contains ordinals greater-than-255 or in the 128-159 range.

If all ordinals are in the 0-127 or 160-255 range, then this program will succeed because the UTF-8 encoded
versions of those characters are the same 1-byte entities as the originals.

But if ANY character has an ordinal not in 0-127 or 160-255 range, an error will result, because the UTF-8
encoded version (which is what the system expects) will not be the same as the Unicode version. For example,


What I've learned from this

=cut

