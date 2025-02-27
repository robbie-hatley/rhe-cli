#!/usr/bin/perl
#  /rhe/scripts/test/test-getfiles.pl

use v5.32;
use strict;
use warnings;

use Cwd;

use RH::Dir;
use RH::Util;

my $files;

my $dir = '/cygdrive/e/Auditorium/Audio/Music/Classical/Ligeti';

my $reg = '.+';

say '';
say 'Regular files:';
$files = GetFiles($dir, 'F', $reg);
foreach (@{$files}) {
   say $_->{Path};
}

say '';
say 'Non-link directories::';
$files = GetFiles($dir, 'D', $reg);
foreach (@{$files}) {
   say $_->{Path};
}

say '';
say 'Both regular files and non-link directories:';
$files = GetFiles($dir, 'B', $reg);
foreach (@{$files}) {
   say $_->{Path};
}

say '';
say 'All files:';
$files = GetFiles($dir, 'A', $reg);
foreach (@{$files}) {
   say $_->{Path};
}

say '';
say 'Names of files in current directory:';
$files = GetFiles;
foreach (@{$files}) {
   say $_->{Name};
}
