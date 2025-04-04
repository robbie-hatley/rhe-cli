#!/usr/bin/env perl

# This is an 110-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# utf8-all-test.pl
# Tests CPAN modules "utf8::all" and "Cwd::utf8", both co-authored by Hayo Baan <info@hayobaan.com>.
# This test file written on Thu Apr 3 2025 by Robbie Hatley.
##############################################################################################################

use v5.16;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;
use utf8::all;
use Cwd::utf8;

chdir '/home/aragorn/Data/Celephais/test-range/unicode-test/煎茶';
my $curdir1 = getcwd                        or die "Couldn't run getcwd.\n";
my $curdir2 = cwd                           or die "Couldn't run cwd.\n";
say "Result from getcwd = \"$curdir1\".";
say "Result from cwd    = \"$curdir2\".";

my $dh = undef;
opendir($dh, "$curdir1")                    or die "Couldn't open  directory.\n";
my @names = sort {$a cmp $b} readdir($dh)   or die "Couldn't read  directory.\n";
closedir($dh)                               or die "Couldn't close directory.\n";

say '';
say "The sorted names from readdir are:";
say for @names;

my @globules = sort {$a cmp $b} glob '* .*' or die "Couldn't glob directory.\n";

say '';
say "The sorted names from glob are:";
say for @globules;

my $fh = undef;
open $fh, '<', '生き甲斐.txt'            or die "Couldn't open  file.";
my @lines = map {chomp;$_} <$fh>            or die "Couldn't read  file.";
close $fh                                   or die "Couldn't close file.";

say '';
say "The lines of file \"生き甲斐.txt\" are:";
say for @lines;

say '';
-f '生き甲斐.txt'
and say "File \"生き甲斐.txt\" is a regular file."
or  say "File \"生き甲斐.txt\" is not a regular file.";

say '';
-d '生き甲斐.txt'
and say "File \"生き甲斐.txt\" is a directory."
or  say "File \"生き甲斐.txt\" is not a directory.";

=pod
NOTE RH 2025-04-03: The result of running this program without "Cwd::utf8" installed was the following,
which shows that CPAN module alone "utf8::all" doesn't work for getting current directory:

Current working directory = "/home/aragorn/Data/Celephais/test-range/unicode-test/çè¶".
readdir() attempted on invalid dirhandle $dh at /usr/share/perl5/site_perl/utf8/all.pm line 264.
closedir() attempted on invalid dirhandle $dh at /d/rhe-cli/scripts/test/utf8-all-test.pl line 26.
The sorted names of the entities in the current directory are:

Note that directory "煎茶" is mis-represented as "çè¶" by getcwd. This does show that the chdir
worked, oddly. But, the getcwd did not. Nor does cwd. Not even with "-C63" in the shebang.

HOWEVER, with CPAN module "Cwd::utf8" also installed, everything works correctly, even with the shebang set to
a simple "#!/usr/bin/env perl".

=cut
