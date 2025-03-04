#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# cwd-glob-readdir-1-test.pl
# Tests using cwd, glob, and readdir with unicode directory and file names, using the "encode_utf8" and
# "decode_utf8" functions from CPAN module "Encode".
#
# Edit history:
# Thu Jan 21, 2021: Wrote it.
# Thu Dec 02, 2021: Updated it.
# Mon Mar 03, 2025: Reduced width from 120 to 110. Got rid of "common::sense", "Sys::Binmode", and "RH::Dir".
#                   Reduced version from "5.36" to "5.16".
##############################################################################################################

use v5.16;
use Cwd;
use Encode;

say '';
say 'cwd test:';
chdir encode_utf8('/d/test-range/unicode-test/茶');
say decode_utf8(cwd);

say '';
say 'glob test:';
say for map {decode_utf8($_)} glob('* .*');

say '';
say 'readdir test:';
my $dh;
opendir($dh, '.') || die "serious dainbramage: $!";
my @allfiles = map {decode_utf8($_)} readdir($dh);
closedir $dh;
say for @allfiles;
