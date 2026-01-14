#!/usr/bin/env perl
use v5.36;
use utf8::all;
$/ = "\0\0";
my $fh = undef;
open($fh, '<', '.sha1tree')
or die "Error: No \".sha1tree\" file found.\n$!\n";
while (<$fh>) {
   s/\0\0$//;
   my ($path, $size, $modt, $sha1) = split "\0", $_;
   next unless defined($path) && length($path) > 0 && '/' eq substr($path,0,1)
            && defined($size) && length($size) > 0 && $size > 0
            && defined($modt) && length($modt) > 0 && $modt > 0
            && defined($sha1) && $sha1 =~ m/^[0-9a-f]{40}$/;
            say '';
   say "PATH = $path";
   say "SIZE = $size";
   say "MODT = $modt";
   say "SHA1 = $sha1";
}

=pod

modt  =              1,745,444,999
2**31 =              2,147,483,648
2**32 =              4,294,967,296
2**63 =  9,223,372,036,850,000,000
2**64 = 18,446,744,073,709,551,616


-2147483648 seconds = 1902AD

=cut
