#!/usr/bin/env -S perl -C63
# print-unicode-test.pl
use v5.16;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;
use Cwd;
use RH::Dir;

my $fh = undef;

say 'chdir to "/d/test-range/unicode-test/煎茶":';
chdir(e('/d/test-range/unicode-test/煎茶'));

say '';
say 'Regular getcwd on "/d/test-range/unicode-test/煎茶" (unlikely to work):';
my $curdir = getcwd;
say "Current directory is \"$curdir\".";

say '';
say 'decoded getcwd on "/d/test-range/unicode-test/煎茶" (should work):';
$curdir = d(getcwd);
say "Current directory is \"$curdir\".";

say '';
say 'Printing WITHOUT :utf8 (should work because -C63 defaults streams to :utf8):';
open $fh, '<', e('Lăn-Lộn-Vài.txt');
print for <$fh>;
close $fh;

say '';
say 'Printing WITH :utf8 (should also work):';
open $fh, '<:utf8', e('Lăn-Lộn-Vài.txt');
print for <$fh>;
close $fh;

say '';
say 'Decoded regular glob on "/d/test-range/unicode-test/煎茶":';
say for sort {$a cmp $b} map {d($_)} glob e('* .*');

say '';
say 'readdir_regexp_utf8 on "/d/test-range/unicode-test/煎茶" (regular files >= 2500B only):';
say for sort {$a cmp $b} readdir_regexp_utf8($curdir, 'F', '.+', '((-s $_)>=2500)');

say '';
say 'glob_regexp_utf8 on "/d/test-range/unicode-test/煎茶" (regular files >= 2500B only):';
say for sort {$a cmp $b} glob_regexp_utf8($curdir, 'F', '.+', '((-s $_)>=2500)');

say '';
say 'Unencoded system echo of "Русский_वासुदेवाय_看的星星":';
system('echo "Русский_वासुदेवाय_看的星星"');

say '';
say 'Encoded system echo of "Русский_वासुदेवाय_看的星星":';
system(e('echo "Русский_वासुदेवाय_看的星星"'));

say '';
say 'Try to mkdir "Русский_वासुदेवाय_看的星星" with backticks, ls it with backticks, and remove it with backticks:';
`mkdir "Русский_वासुदेवाय_看的星星"`;
say 'Exit code of "mkdir" was ', $? >> 8;
print for `ls -d Рус*`;
`rm -r "Русский_वासुदेवाय_看的星星"`;
say 'Exit code of "rm -r" was ', $? >> 8;
