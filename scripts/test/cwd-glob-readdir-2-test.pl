#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# cwd-glob-readdir-test-2.pl
# Tests using cwd, glob, and readdir with unicode directory and file names, using my utf8 versions of various
# funcitons.
#
# Edit history:
# Thu Jan 21, 2021: Wrote it.
# Thu Dec 02, 2021: Updated it.
# Mon Mar 03, 2025: Reduced width from 120 to 110. Got rid of "common::sense", "Sys::Binmode"
##############################################################################################################

use v5.16;
use utf8;
use Cwd;
use RH::Dir;

say '';
say 'cwd test:';
chdir(e('/d/test-range/unicode-test/煎茶')) or die "Couldn't change directory!\n";
my $curdir = d(getcwd);
say "Current directory = \"$curdir\"";

say '';
say 'glob test:';
say for sort {$a cmp $b} map {d($_)} glob(e('* .*'));

say '';
say 'readdir test:';
my $dh;
opendir($dh, e('.')) || die "Error: Couldn't open directory \"$curdir\"\n";
say for sort {$a cmp $b} map {d($_)} readdir($dh);
closedir $dh;
