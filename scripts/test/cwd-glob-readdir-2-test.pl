#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# cwd-glob-readdir-test-2.pl
# Tests using cwd, glob, and readdir with unicode directory and file names, using my utf8 versions of various funcitons.
#
# Edit history:
# Thu Jan 21, 2021: Wrote it.
# Thu Dec 02, 2021: Updated it.
########################################################################################################################

use v5.32;
use common::sense;
use Sys::Binmode;
use Cwd;
use RH::Dir;

say '';
say 'cwd test:';
chdir e '/d/test-range/unicode-test/茶';
say cwd_utf8();

say '';
say 'glob test:';
say for glob_utf8('* .*');

say '';
say 'readdir test:';
my $dh;
opendir_utf8($dh, ".") || die "serious dainbramage: $!";
my @allfiles = readdir_utf8 $dh;
closedir $dh;
say for @allfiles;
