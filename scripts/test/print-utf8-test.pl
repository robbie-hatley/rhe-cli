#!/usr/bin/env -S perl -CSDA
# print-utf8-test.pl
use v5.32;
use warnings FATAL => "utf8";
use utf8;

use RH::Dir;

my $fh;

chdir '/D/test-range/unicode-test';

say '';
say 'Printing WITHOUT :utf8 :';
open $fh, '<', 'vietnamese.txt';
for my $line (<$fh>)
{
   print $line;
}
close $fh;

say '';
say 'Printing WITH :utf8 :';
open $fh, '<:utf8', 'vietnamese.txt';
for my $line (<$fh>)
{
   print $line;
}
close $fh;

chdir '/D/test-range/unicode-test/Asia';

say '';
say 'Regular glob on Asia folder:';
say for glob '* .*';

say '';
say 'glob_regexp_utf8 on Asia folder:';
say get_name_from_path($_) for glob_regexp_utf8;

chdir '/D/test-range/unicode-test/茶';

say '';
say 'Regular cwd on 茶:';
say cwd;

say '';
say 'cwd_utf8 on 茶:';
say cwd_utf8;

say '';
system 'echo', 'épée';

say '';
chdir
`mkdir 'épée_UTF8'`;
`ls`;
